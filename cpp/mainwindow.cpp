#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>
#include <QDebug>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    dataCode = 0;
    dataZacode = 0;
    dataComeCode = 0;
    vjitaliyal.dataNum = 0;

    //connect code
    code[0] = ui->checkBox_CorerB_0;
    code[1] = ui->checkBox_CorerB_1;
    code[2] = ui->checkBox_CorerB_2;
    code[3] = ui->checkBox_CorerB_3;
    code[4] = ui->checkBox_CorerB_4;
    code[5] = ui->checkBox_CorerB_5;
    code[6] = ui->checkBox_CorerB_6;
    code[7] = ui->checkBox_CorerB_7;
    for(int i = 0; i < 8; i++)
        connect(code[i], SIGNAL(clicked(bool)), this, SLOT(changeCode()));

    //connect data
    dataC[0] = ui->checkBox_DataB_0;
    dataC[1] = ui->checkBox_DataB_1;
    dataC[2] = ui->checkBox_DataB_2;
    dataC[3] = ui->checkBox_DataB_3;
    dataC[4] = ui->checkBox_DataB_4;
    dataC[5] = ui->checkBox_DataB_5;
    dataC[6] = ui->checkBox_DataB_6;
    dataC[7] = ui->checkBox_DataB_7;
    dataC[8] = ui->checkBox_DataB_8;
    dataC[9] = ui->checkBox_DataB_9;
    dataC[10] = ui->checkBox_DataB_10;
    dataC[11] = ui->checkBox_DataB_11;
    dataC[12] = ui->checkBox_DataB_12;
    dataC[13] = ui->checkBox_DataB_13;
    dataC[14] = ui->checkBox_DataB_14;
    dataC[15] = ui->checkBox_DataB_15;

    for(int i = 0; i < 16; i++)
        connect(dataC[i], SIGNAL(clicked(bool)), this, SLOT(changeData()));
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::changeCode()
{
    dataCode = 0;
    for(int i = 0; i < 8; i++)
        dataCode |= ((quint16)(code[i]->isChecked())) << i;

    ui->lcdNumber_code->display(dataCode);
}

void MainWindow::on_pushButton_coder_clicked()
{
    quint8 shiftReg = 0;
    dataZacode = 0;
    for(int i = 0; i < 8; i++)
    {
        shiftReg = (shiftReg << 1) | ((dataCode >> i) & 0x01);//здвигаю регистр
        quint16 /*bool*/ b1 = (shiftReg & 0x01) ^ ((shiftReg >> 1) & 0x01) ^ ((shiftReg >> 2) & 0x01);//1 бит
                                    //0                     1                           2
        quint16 /*bool*/ b0 = (shiftReg & 0x01) ^ ((shiftReg >> 2) & 0x01);//0 бит
                                    //0                     2
        b0 = b0 & 0x01;
        b1 = (b1 & 0x01) << 1;
        dataZacode |= (b0 | b1) << i*2;//выставляю биты на нужнуую позицию
    }
    ui->lcdNumber_zaCode->display(dataZacode);
    for(int i = 0; i < 16; i++)
    {
        dataC[i]->setChecked((dataZacode >> i) & 0x01);
    }

    changeData();
}

void MainWindow::changeData()
{
    dataComeCode = 0;
    for(int i = 0; i < 16; i++)
        dataComeCode |= ((quint16)(dataC[i]->isChecked())) << i;

    ui->lcdNumber_data->display(dataComeCode);
}

void MainWindow::on_pushButton_decoder_clicked()
{
    quint8 codeDecoder = 0;
    vjitaliyal.dataNum = 0;
    vjitaliyal.dataSt.bitDecodering = 0;
    vjitaliyal.dataSt.noErrorBit = 0;
    vjitaliyal.dataSt.nowSt = 0;
    vjitaliyal.dataSt.oldererSt = 0;
    vjitaliyal.dataSt.olderSt = 0;
    vjitaliyal.dataSt.oldSt = 0;

//    qDebug() << dataComeCode;
    ui->textBrowser_error->append("Decoder code" + QByteArray::number(dataComeCode, 16));

    bool codeDecoderBin[8] = {0};

    for(int i = 0; i < 8; i++)
    {
        decoderViterbi((dataComeCode >> (2*i + 1)) & 0x01, (dataComeCode >> (2*i)) & 0x01, codeDecoderBin);
    }

    for(int i = 0; i < 8; i++)
        codeDecoder |= ((quint8)codeDecoderBin[i]) << i;

    ui->lcdNumber_decode->display(codeDecoder);

    ui->textBrowser_error->append("Result decoder" + QByteArray::number(codeDecoder, 16));
}

bool MainWindow::deleteError(ViterbiDecoderUnion *val, bool *dataOut)
{
    ui->textBrowser_error->append("data code:"  + QByteArray::number(val->dataSt.nowSt, 2).rightJustified(2, '0') + " " \
                                                + QByteArray::number(val->dataSt.oldSt, 2).rightJustified(2, '0') + " "\
                                                + QByteArray::number(val->dataSt.olderSt, 2).rightJustified(2, '0') + " "\
                                                + QByteArray::number(val->dataSt.oldererSt, 2).rightJustified(2, '0') + " ");
    //мне пришло YYYYxxYY где xx один из битов ошибочный
    //на выходе могут получится ННxx т.е. 4 возможные вариации
    //просто закодирую эти 4 вариации и найду ту где 2 последних бита совпадут
    quint8 valVar[4] = {0};
    quint8 codeData = 0;

    //обойдусь без цикла если первых битов нету то заполняжю 0
    if(val->dataSt.bitDecodering > 1)
        codeData |= (quint8)dataOut[val->dataSt.bitDecodering - 2];

    if(val->dataSt.bitDecodering > 0)
        codeData |= ((quint8)dataOut[val->dataSt.bitDecodering - 1]) << 1;

    for(quint8 i = 0; i < 4; i++)
    {
        codeData = codeData & 0x03;
        codeData |= i << 2;
        //code data
        quint8 shiftReg = 0;
        for(int j = 0; j < 4; j++)
        {
            shiftReg = (shiftReg << 1) | ((codeData >> j) & 0x01);//здвигаю регистр
            quint16 /*bool*/ b0 = (shiftReg & 0x01) ^ ((shiftReg >> 1) & 0x01) ^ ((shiftReg >> 2) & 0x01);//1 бит
                                        //0                     1                           2
            quint16 /*bool*/ b1 = (shiftReg & 0x01) ^ ((shiftReg >> 2) & 0x01);//0 бит
                                        //0                     2
            b0 = b0 & 0x01;
            b1 = (b1 & 0x01) << 1;
            valVar[i] |= (b0 | b1) << j*2;//выставляю биты на нужнуую позицию

        }
        //первые биты должныы быть от предыдушего
        valVar[i] &= 0xF0;
        valVar[i] |= val->dataSt.olderSt << 2;
        valVar[i] |= val->dataSt.oldererSt;
        ui->textBrowser_error->append("VariantCode " + QByteArray::number(i) + " :" + QByteArray::number(valVar[i], 2).rightJustified(8, '0'));
        //делаю проверку на 2 два бита
        quint8 tmp = valVar[i] >> 6;
        if(tmp == val->dataSt.nowSt)//если дла бита совпали
        {
//            qDebug() << i << "Poxoje";
            //еще должен совпасть 1 из битов
            tmp = (valVar[i] >> 4) & 0x03;
//            qDebug() << "tmp " << tmp;
//            qDebug() << "data " << val->dataSt.oldSt;
            if(((tmp & 0x02) == (val->dataSt.oldSt & 0x02)) || (tmp & 0x01) == (val->dataSt.oldSt & 0x01))
            {
                vjitaliyal.dataSt.shiftReg = (vjitaliyal.dataSt.shiftReg << 2) & 0x07;
                vjitaliyal.dataSt.shiftReg |= (i & 0x01) << 1;
                vjitaliyal.dataSt.shiftReg |= (i & 0x02) >> 1;
                val->dataSt.oldSt = tmp;
                dataOut[val->dataSt.bitDecodering++] = i & 0x01;
                dataOut[val->dataSt.bitDecodering++] = i & 0x02;
                ui->textBrowser_error->append("OK error pravelnii variant:" + QByteArray::number(i));
                return true;
            }
        }

    }

    return false;
}

bool MainWindow::decoderViterbi(bool b0, bool b1, bool *dataOut)
{
    //https://www.sibsau.ru/sveden/edufiles/127954/
    //ст 9
//    static bool errorBit = false;//если предыдуший бит оказался ошибочнйы
//    static bool iter = 0;//номер раскодируюемого бита
//    static bool oldB0 = false, oldB1 = false;//старые состояния
//    static bool olderB0 = false, olderB1 = false;//более страрые состояния

    vjitaliyal.dataSt.nowSt = ((quint8)b1 << 1) | b0;
    if(vjitaliyal.dataSt.noErrorBit)//если была ошибка
    {
//        qDebug() << "Ny oshibca";
        //функция для исправления ошибок
        ui->textBrowser_error->append("Ny oshibca pridetsy ispravlat");
        deleteError(&vjitaliyal, dataOut);

        vjitaliyal.dataSt.noErrorBit = false;
    }
    else//если все идет ОК
    {
        vjitaliyal.dataSt.shiftReg = (vjitaliyal.dataSt.shiftReg << 1) & 0x07;//сдвигаю на 1 бит

        //биты при 0
        bool b00 = ((vjitaliyal.dataSt.shiftReg >> 1) & 0x01) ^ ((vjitaliyal.dataSt.shiftReg >> 2) & 0x01);//1 бит
        bool b10 = ((vjitaliyal.dataSt.shiftReg >> 2) & 0x01);//0 бит
        //биты при 1
        bool b01 = (0x01) ^ ((vjitaliyal.dataSt.shiftReg >> 1) & 0x01) ^ ((vjitaliyal.dataSt.shiftReg >> 2) & 0x01);//1 бит
        bool b11 = (0x01) ^ ((vjitaliyal.dataSt.shiftReg >> 2) & 0x01);//0 бит

        if((b0 == b00) && (b1 == b10))
        {
            dataOut[vjitaliyal.dataSt.bitDecodering++] = 0;
        }
        else if((b0 == b01) && (b1 == b11))
        {
            vjitaliyal.dataSt.shiftReg |= 0x01;
            dataOut[vjitaliyal.dataSt.bitDecodering++] = 1;
        }
        else
        {
            vjitaliyal.dataSt.noErrorBit = true;
            ui->textBrowser_error->append("ERROR 0 bit:" + QByteArray::number(vjitaliyal.dataSt.bitDecodering));
        }
    }


    vjitaliyal.dataSt.oldererSt= vjitaliyal.dataSt.olderSt;
    vjitaliyal.dataSt.olderSt = vjitaliyal.dataSt.oldSt;//сдвигаю состояния они теперь старые
    vjitaliyal.dataSt.oldSt = vjitaliyal.dataSt.nowSt;
    return vjitaliyal.dataSt.noErrorBit;
}

void MainWindow::on_pushButton_clicked()
{
    ui->textBrowser_error->clear();
}
