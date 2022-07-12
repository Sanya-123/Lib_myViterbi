#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QCheckBox>

namespace Ui {
class MainWindow;
}

//#pragma pack//для сжатия между
#pragma pack(push, 1)//идет сужение
typedef struct {
    quint8 nowSt : 2;
    quint8 oldSt : 2;
    quint8 olderSt : 2;
    quint8 oldererSt : 2;
    bool noErrorBit : 1;
    quint8 shiftReg : 3;
    quint16 reserv : 4;//эти биты не используются ну я их так добавил чтобы получилос 32 бита
    quint16 bitDecodering : 16;//номер декодируюемого бита
}ViterbiDecoderSt;

#pragma pack(pop)//возвращение предыдущих настроек

union ViterbiDecoderUnion{
    ViterbiDecoderSt dataSt;
    quint32 dataNum;
};

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    /**
     * @brief decoderViterbi - функция декодирования кода витерби
     * @param b0 - первый бит
     * @param b1 - второй бит
     * @param dataOut - раскодированый бмнарный код нужно задовать массив
     * @return если ошибки не было то true иначе false
     */
    bool decoderViterbi(bool b0, bool b1, bool *dataOut);
    bool deleteError(ViterbiDecoderUnion *val, bool *dataOut);


private slots:
    void changeCode();
    void changeData();
    void on_pushButton_coder_clicked();

    void on_pushButton_decoder_clicked();

    void on_pushButton_clicked();

private:
    ViterbiDecoderUnion vjitaliyal;
    quint16 dataCode;
    quint16 dataZacode;
    quint16 dataComeCode;
    QCheckBox *code[8];
    QCheckBox *dataC[16];
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
