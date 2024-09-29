package com.savanitdevthermalprinter;

import static android.content.Context.BIND_AUTO_CREATE;
import static com.savanitdevthermalprinter.SavanitdevThermalPrinterModule.decodeBase64ToBitmap;
import static com.savanitdevthermalprinter.SavanitdevThermalPrinterModule.myBinder;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ViewManager;

import net.posprinter.POSConnect;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import zywell.posprinter.posprinterface.ProcessData;
import zywell.posprinter.posprinterface.TaskCallback;
import zywell.posprinter.service.PosprinterService;
import zywell.posprinter.utils.BitmapProcess;
import zywell.posprinter.utils.BitmapToByteData;
import zywell.posprinter.utils.DataForSendToPrinterPos58;
import zywell.posprinter.utils.DataForSendToPrinterPos80;
import zywell.posprinter.utils.DataForSendToPrinterTSC;
import zywell.posprinter.utils.PosPrinterDev;

@ReactModule(name = ZyWell.NAME)
public class ZyWell extends ReactContextBaseJavaModule {
    public static final String NAME = "ZyWell";
    Context context;
    @NonNull
    @Override
    public String getName() {
        return NAME;
    }
    public ZyWell(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }

    // multiple connection
    private void AddPrinter(PosPrinterDev.PrinterInfo printer, Promise promise) {
        myBinder.AddPrinter(printer, new TaskCallback() {
            @Override
            public void OnSucceed() {
                WritableMap result = Arguments.createMap();
                result.putString("printerName", printer.printerName);
                result.putString("portInfo", printer.portInfo);
                result.putString("printerType", String.valueOf(printer.printerType));
                result.putString("status", String.valueOf(printer.status));
                promise.resolve(result);
            }
            @Override
            public void OnFailed() {
                promise.reject("ERROR", "CONNECT_FAIL");
            }
        });
    }
    @ReactMethod
    public void disconnectMultiZyWell(String printerName, Promise promise) {
        if (printerName != null) {

            boolean isValidate = findPrinterByName(printerName);
            Log.e("isValidate", String.valueOf(isValidate));
            if (isValidate) {
                myBinder.RemovePrinter(printerName, new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        promise.resolve("REMOVE_DONE");
                    }

                    @Override
                    public void OnFailed() {
                        promise.resolve("REMOVE_FAIL");
                    }
                });
            } else {
                promise.reject(new Exception("NO_PRINTER_IN_LIST"));
            }
        } else {
            promise.reject(new Exception("NOT_FOUND_NAME"));
        }
    }

    @ReactMethod
    public void connectMultiZyWell(String address, int portType, final Promise promise) {
        if (address != "") {
            String name = "printer" + myBinder.GetPrinterInfoList().size();
            PosPrinterDev.PrinterInfo printer;
            switch (portType) {
                case 0:
                    printer = new PosPrinterDev.PrinterInfo(name, PosPrinterDev.PortType.Ethernet, address);
                    AddPrinter(printer, promise);
                    break;
                case 1:
                    String mac = address.toString().trim();
                    printer = new PosPrinterDev.PrinterInfo(name, PosPrinterDev.PortType.Bluetooth, mac);
                    AddPrinter(printer, promise);
                    break;
                case 2:
                    String usbAddress = address.toString().trim();
                    printer = new PosPrinterDev.PrinterInfo(name, PosPrinterDev.PortType.USB, usbAddress);
                    printer.context = context;
                    AddPrinter(printer, promise);
                    break;
            }

        } else {
            promise.reject(new Exception("CONNECT_ADDRESS_FAIL_NULL"));
        }
    }

    @ReactMethod
    public void printImgMultiZyWell(String printerName, String base64String, int width, Promise promise) {
        if (printerName != null) {
            boolean isValidate = findPrinterByName(printerName);
            if (isValidate) {
                final Bitmap bitmap = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
                myBinder.SendDataToPrinter(printerName, new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        promise.resolve("PRINT_SUCCESS");
                    }

                    @Override
                    public void OnFailed() {
                        promise.reject(new Exception("PRINT_FAIL"));
                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {
                        List<byte[]> list = new ArrayList<>();
                        final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(bitmap, width);
                        list.add(DataForSendToPrinterPos80.initializePrinter());
                        list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmap1,
                                BitmapToByteData.BmpType.Dithering,
                                BitmapToByteData.AlignType.Center, width));
                        list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
                        return list;
                    }
                });
            } else {
                promise.reject(new Exception("PRINTER_NAME_FAIL"));
            }
        } else {
            promise.reject(new Exception("NO_PRINTER_NAME"));
        }
    }

    @ReactMethod
    public void printRawDataMulti(String printerName, String base64String, Promise promise) {
        if (printerName != null) {
            boolean isValidate = findPrinterByName(printerName);
            // Log.e("isValidate", String.valueOf(isValidate));
            if (isValidate) {
                byte[] bytes = Base64.decode(base64String, Base64.DEFAULT);
                myBinder.SendDataToPrinter(printerName, new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        promise.resolve("PRINT_SUCCESS");
                    }

                    @Override
                    public void OnFailed() {
                        promise.reject(new Exception("PRINT_FAIL"));
                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {
                        List<byte[]> list = new ArrayList<>();
                        list.add(bytes);
                        return list;
                    }
                });
            } else {
                promise.reject(new Exception("PRINTER_NAME_FAIL"));
            }
        } else {
            promise.reject(new Exception("NO_PRINTER_NAME"));
        }
    }

    @ReactMethod
    private void getPrinterInfoListMulti(Promise promise) {
        try {
            String data = String.valueOf(myBinder.GetPrinterInfoList().toString());
            promise.resolve(data);
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
            throw new RuntimeException(e);
        }
    }

    @ReactMethod
    private void printImgWithTimeoutMulti(String printerName,String base64String, int page, boolean isCut, int width, int cutCount,
                                     int timeout, Promise promise) {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
        myBinder.SendDataToPrinter(printerName, new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("SEND_SUCCESS");
                }
                @Override
                public void OnFailed() {
                    promise.reject("ERROR", "PRINT_FAIL");
                    // disConnectNet(promise);
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    if (page == 58) {
                        list.add(DataForSendToPrinterPos58.initializePrinter());
                    } else {
                        list.add(DataForSendToPrinterPos80.initializePrinter());
                    }
                    List<Bitmap> blist = new ArrayList<>();
                    blist = BitmapProcess.cutBitmap(cutCount, bitmap1);
                    for (int i = 0; i < blist.size(); i++) {
                        if (page == 58) {
                            list.add(DataForSendToPrinterPos58.printRasterBmp(
                                    0, blist.get(i), BitmapToByteData.BmpType.Dithering,
                                    BitmapToByteData.AlignType.Left, width));
                        } else {
                            list.add(DataForSendToPrinterPos80.printRasterBmp(
                                    0, blist.get(i), BitmapToByteData.BmpType.Dithering,
                                    BitmapToByteData.AlignType.Left, width));
                        }
                    }

                    if (page == 58 && isCut) {
                        list.add(DataForSendToPrinterPos58.printAndFeedLine());
                    } else if (isCut) {
                        list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    }

                    if (page == 80 && isCut) {
                        list.add(
                                DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(
                                        0x42, 0x66));
                    }
                    return list;
                }
            });

    }

    // Method to find a printer by its name
    public boolean findPrinterByName(String printerName) {
        for (int i = 0; i < myBinder.GetPrinterInfoList().size(); i++) {
            Log.e("printerName", printerName);
            Log.e("GET GetPrinterInfoList", myBinder.GetPrinterInfoList().get(i).printerName);
            Log.e("GetPrinterInfoList ",
                    String.valueOf(myBinder.GetPrinterInfoList().get(i).printerName.equals(printerName.toString())));
            if (myBinder.GetPrinterInfoList().get(i).printerName.equals(printerName.toString())) {
                return true;
            }
        }
        return false;
    }
    @ReactMethod
     public void getPrinterStatusZyWell(String printerName,Promise promise) {
        try
       {
          String status = String.valueOf(myBinder.GetPrinterStatus(printerName));
           promise.resolve(status);
       }catch (Exception e){
           promise.reject("ERROR",e.toString());
       }

     }

    // single connection
    @ReactMethod
    public void connectNetZyWell(String ip, Promise promise) {
        myBinder.ConnectNetPort(ip, 9100, new TaskCallback() {
            @Override
            public void OnSucceed() {
                promise.resolve("CONNECTED");
            }
            @Override
            public void OnFailed() {
                promise.reject("ERROR", "DISCONNECT");

            }
        });
    }
    @ReactMethod
    public void connectBTZyWell(String macAddress, Promise promise) {
        myBinder.ConnectBtPort(macAddress, new TaskCallback() {
            @Override
            public void OnSucceed() {
                promise.resolve("CONNECTED");
            }
            @Override
            public void OnFailed() {
                promise.reject("ERROR", "CONNECT_FAIL");
            }
        });
    }
    @ReactMethod
    public void connectUSBZyWell(String usbAddress, Promise promise) {
        if (usbAddress != null) {
            myBinder.ConnectUsbPort(context.getApplicationContext(), usbAddress, new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("ISCONNECT");
                }
                @Override
                public void OnFailed() {
                    promise.reject("error","ISCONNECT");
                }
            });

        } else {
            promise.reject("ERROR", "NO_ADDRESS");
        }
    }
    @ReactMethod
    public void disConnectZyWell(Promise promise) {
        myBinder.DisconnectCurrentPort(new TaskCallback() {
            @Override
            public void OnSucceed() {
                promise.resolve("DISCONNECT");
            }
            @Override
            public void OnFailed() {
                promise.reject("ERROR","DISCONNECT_FAIL");
            }
        });
    }
    @ReactMethod
    public void disConnectNetZyWell(Promise promise) {
        myBinder.DisconnetNetPort(new TaskCallback() {
            @Override
            public void OnSucceed() {
                promise.resolve("DISCONNECT");
            }
            @Override
            public void OnFailed() {
                promise.reject("ERROR","DISCONNECT_FAIL");
            }
        });
    }


    @ReactMethod
    public void getPrinterStatus( Promise promise) {
    try {
        myBinder.StopMonitorPrinter();
    }catch (Exception e){
        promise.reject("ERROR",e.toString());
     }
    }
    @ReactMethod
    public void printRawZyWell(String encode, Promise promise) {
        byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
        myBinder.Write(bytes, new TaskCallback() {
            @Override
            public void OnSucceed() {
                promise.resolve("PRINT_DONE");
            }
            @Override
            public void OnFailed() {
                promise.reject("ERROR", "PRINT_FAIL");
            }
        });
    }
    @ReactMethod
    public void printImgZyWell(String base64String, int width, boolean isCut, Promise promise) {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("PRINT_DONE");
                }
                @Override
                public void OnFailed() {
                    promise.reject("ERROR", "PRINT_FAIL");
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmap1, BitmapToByteData.BmpType.Dithering,
                            BitmapToByteData.AlignType.Center, width));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    if (isCut) {
                        list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
                    }
                    return list;
                }
            });
    }
    @ReactMethod
    public void printImgWithTimeoutZyWell(String base64String, int page, boolean isCut, int width, int cutCount,
                                     int timeout, Promise promise) {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);

            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("SEND_SUCCESS");
                        TimerTask task = new TimerTask() {
                            @Override
                            public void run() {
                                disConnectZyWell(promise);
                            }
                        };
                        Timer timer = new Timer();
                        timer.schedule(task, timeout);

                }

                @Override
                public void OnFailed() {
                    promise.reject("ERROR", "PRINT_FAIL");
                    // disConnectNet(promise);
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    if (page == 58) {
                        list.add(DataForSendToPrinterPos58.initializePrinter());
                    } else {
                        list.add(DataForSendToPrinterPos80.initializePrinter());
                    }
                    List<Bitmap> blist = new ArrayList<>();
                    blist = BitmapProcess.cutBitmap(cutCount, bitmap1);
                    for (int i = 0; i < blist.size(); i++) {
                        if (page == 58) {
                            list.add(DataForSendToPrinterPos58.printRasterBmp(
                                    0, blist.get(i), BitmapToByteData.BmpType.Dithering,
                                    BitmapToByteData.AlignType.Left, width));
                        } else {
                            list.add(DataForSendToPrinterPos80.printRasterBmp(
                                    0, blist.get(i), BitmapToByteData.BmpType.Dithering,
                                    BitmapToByteData.AlignType.Left, width));
                        }
                    }

                    if (page == 58 && isCut) {
                        list.add(DataForSendToPrinterPos58.printAndFeedLine());
                    } else if (isCut) {
                        list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    }

                    if (page == 80 && isCut) {
                        list.add(
                                DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(
                                        0x42, 0x66));
                    }
                    return list;
                }
            });

    }

    @ReactMethod
    public void printImgTSCZyWell(String base64String, int width,boolean type, int m, int n,int x,int y,int mode, Promise promise) {
        final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
        myBinder.WriteSendData(new TaskCallback() {
            @Override
            public void OnSucceed() {
                promise.resolve("PRINT_DONE");
            }
            @Override
            public void OnFailed() {
                promise.reject("ERROR", "PRINT_FAIL");
            }
        }, new ProcessData() {
            @Override
            public List<byte[]> processDataBeforeSend() {
                List<byte[]> list = new ArrayList<>();
                list.add(DataForSendToPrinterTSC.sizeBymm(m,n));
                list.add(DataForSendToPrinterTSC.bitmap(x,y,mode,bitmap1, type ? BitmapToByteData.BmpType.Threshold : BitmapToByteData.BmpType.Dithering));
                list.add(DataForSendToPrinterTSC.print(1));
                list.add(DataForSendToPrinterPos80.printAndFeedLine());
                return list;
            }
        });
    }

}
