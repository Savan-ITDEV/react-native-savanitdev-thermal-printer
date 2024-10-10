package com.savanitdevthermalprinter;

import static android.content.Context.BIND_AUTO_CREATE;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.IBinder;
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
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ViewManager;

import net.posprinter.POSConnect;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import zywell.posprinter.posprinterface.IMyBinder;
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
    public static IMyBinder myZyWell;
    @NonNull
    @Override
    public String getName() {
        return NAME;
    }

    ServiceConnection mSerconnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            myZyWell = (IMyBinder) service;
            Log.e("myZyWell", "connect");
            // Toast toast = Toast.makeText(context, "connect", Toast.LENGTH_SHORT);
            // toast.show();
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.e("myZyWell", "disconnect");
            myZyWell = null;
            // Toast toast = Toast.makeText(context, "disconnect", Toast.LENGTH_SHORT);
            // toast.show();
        }
    };

    public ZyWell(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
        try {
            Log.e("myZyWell", "initial printer");
            Intent intent = new Intent(context, PosprinterService.class);
            context.bindService(intent, mSerconnection, BIND_AUTO_CREATE);


        } catch (Exception e) {
            Log.d("myZyWell ERROR", "Exception--: " + e);
        }
    }
    private boolean pingHost(String str,int timeout) {
        boolean result = false;
        BufferedReader bufferedReader = null;
        Process p = null;
        try {
            Thread.sleep(timeout);
            p = Runtime.getRuntime().exec("ping -c 1 -w 5 " + str);
            InputStream ins = p.getInputStream();
            InputStreamReader reader = new InputStreamReader(ins);
            bufferedReader = new BufferedReader(reader);
            Object var6 = null;
            while(true) {
                if (bufferedReader.readLine() == null) {
                    int status = p.waitFor();
                    if (status == 0) {
                        result = true;
                    } else {
                        result = false;
                    }
                    break;
                }
            }
        } catch (IOException var18) {
            result = false;
        } catch (InterruptedException var19) {
            result = false;
        } finally {
            if (p != null) {
                p.destroy();
            }
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (IOException var17) {
                    IOException var17x = var17;
                    var17x.printStackTrace();
                }
            }

        }
        return result;
    }

    @ReactMethod
    public void isOnline(String address,int timeout, Promise promise) {
        if (address != null) {
            boolean isConnected = pingHost(address,timeout);
            promise.resolve(isConnected);
        } else {
            promise.reject("ERROR", "DISCONNECT");
        }
    }

    // multiple connection
    private void AddPrinter(PosPrinterDev.PrinterInfo printer, Promise promise) {
        myZyWell.AddPrinter(printer, new TaskCallback() {
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
    public void disconnectMultiZyWell(String printerName, Promise promise)
    {
        if (printerName != null) {

            boolean isValidate = findPrinterByName(printerName);
            Log.e("isValidate", String.valueOf(isValidate));

            if (isValidate) {

                myZyWell.RemovePrinter(printerName, new TaskCallback() {
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
            boolean isValidate = findPrinterByName(address);
            Log.e("isValidate", String.valueOf(isValidate));
            if(isValidate){
                promise.resolve("CONNECTED");
            }else{
            PosPrinterDev.PrinterInfo printer;
            switch (portType) {
                case 0:
                    printer = new PosPrinterDev.PrinterInfo(address, PosPrinterDev.PortType.Ethernet, address);
                    AddPrinter(printer, promise);
                    break;
                case 1:
                    String mac = address.trim();
                    printer = new PosPrinterDev.PrinterInfo(address, PosPrinterDev.PortType.Bluetooth, mac);
                    AddPrinter(printer, promise);
                    break;
                case 2:
                    String usbAddress = address.toString().trim();
                    printer = new PosPrinterDev.PrinterInfo(address, PosPrinterDev.PortType.USB, usbAddress);
                    printer.context = context;
                    AddPrinter(printer, promise);
                    break;
            }
        }
        } else {
            promise.reject(new Exception("CONNECT_ADDRESS_FAIL_NULL"));
        }
    }

    public static Bitmap decodeBase64ToBitmap(String base64String) {
        byte[] decodedBytes = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.FROYO) {
            decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
        }
        return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
    }
    @ReactMethod
    public void printImgMultiZyWell(String printerName, String base64String, int width, Promise promise) {
        if (printerName != null) {
            boolean isValidate = findPrinterByName(printerName);

            if (isValidate) {

                final Bitmap bitmap = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
                final Bitmap bitmapToPrint = convertGreyImg(bitmap);
                myZyWell.SendDataToPrinter(printerName, new TaskCallback() {
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
                       
                        list.add(DataForSendToPrinterPos80.initializePrinter());
                        list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmapToPrint,
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
                byte[] bytes = null;
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.FROYO) {
                    bytes = Base64.decode(base64String, Base64.DEFAULT);
                }
                byte[] finalBytes = bytes;
                myZyWell.SendDataToPrinter(printerName, new TaskCallback() {
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
                        list.add(finalBytes);
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
            WritableArray result = Arguments.createArray();
            for (int i = 0; i < myZyWell.GetPrinterInfoList().size(); i++) {

                WritableMap printerMap = Arguments.createMap();
               String printerName = myZyWell.GetPrinterInfoList().get(i).printerName;
               String printerType = myZyWell.GetPrinterInfoList().get(i).printerType.name();
               String portInfo = myZyWell.GetPrinterInfoList().get(i).portInfo;
                printerMap.putString("printerName",printerName);
                printerMap.putString("printerType", printerType);
                printerMap.putString("portInfo",portInfo);

                // Add the object to the array
                result.pushMap(printerMap);
            }
//            String data = String.valueOf(myZyWell.GetPrinterInfoList());
//            Log.e("GetPrinterInfoList ",result.toString());
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
            throw new RuntimeException(e);
        }
    }

    @ReactMethod
    private void printImgWithTimeoutMulti(String printerName,String base64String, int page, boolean isCut, int width, int cutCount,
                                          int timeout, Promise promise) {
        final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
        final Bitmap bitmapToPrint =   convertGreyImg(bitmap1);
        
        myZyWell.SendDataToPrinter(printerName, new TaskCallback() {
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
                blist = BitmapProcess.cutBitmap(cutCount, bitmapToPrint);
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
        for (int i = 0; i < myZyWell.GetPrinterInfoList().size(); i++) {
            Log.e("printerName", printerName);
            Log.e("GET GetPrinterInfoList", myZyWell.GetPrinterInfoList().get(i).printerName);
            Log.e("GetPrinterInfoList ",
                    String.valueOf(myZyWell.GetPrinterInfoList().get(i).printerName.equals(printerName.toString())));
            if (myZyWell.GetPrinterInfoList().get(i).printerName.equals(printerName.toString())) {
                return true;
            }
        }
        return false;
    }
    @ReactMethod
    public void getPrinterStatusZyWell(String printerName,Promise promise) {
        try
        {
            String status = String.valueOf(myZyWell.GetPrinterStatus(printerName));
            promise.resolve(status);
        }catch (Exception e){
            promise.reject("ERROR",e.toString());
        }

    }

    // single connection
    @ReactMethod
    public void connectNetZyWell(String ip, Promise promise) {
        myZyWell.ConnectNetPort(ip, 9100, new TaskCallback() {
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
        myZyWell.ConnectBtPort(macAddress, new TaskCallback() {
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
            myZyWell.ConnectUsbPort(context.getApplicationContext(), usbAddress, new TaskCallback() {
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
        myZyWell.DisconnectCurrentPort(new TaskCallback() {
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
        myZyWell.DisconnetNetPort(new TaskCallback() {
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
    public void clearBufferZyWell(Promise promise) {
        try {
            myZyWell.OnDiscovery(PosPrinterDev.PortType.Ethernet,context);
            myZyWell.ClearBuffer();
            promise.resolve("true");
        } catch (Exception e) {
            promise.reject("ERROR",e.toString());
        }
    }
    @ReactMethod
    public void getPrinterStatusSGZyWell(Promise promise) {
        try {
            String status = String.valueOf(myZyWell.GetPrinterStatus());
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject("ERROR",e.toString());
        }
    }


    @ReactMethod
    public void stopMonitorPrinter(Promise promise) {
        try {
            myZyWell.StopMonitorPrinter();
        }catch (Exception e){
            promise.reject("ERROR",e.toString());
        }
    }
    @ReactMethod
    public void printRawZyWell(String encode, Promise promise) {
        byte[] bytes = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.FROYO) {
            bytes = Base64.decode(encode, Base64.DEFAULT);
        }
        myZyWell.Write(bytes, new TaskCallback() {
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
        final Bitmap bitmapToPrint =   convertGreyImg(bitmap1);
        myZyWell.WriteSendData(new TaskCallback() {
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
                list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmapToPrint, BitmapToByteData.BmpType.Dithering,
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
                                          Promise promise) {
        final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
        final Bitmap bitmapToPrint =   convertGreyImg(bitmap1);
        myZyWell.WriteSendData(new TaskCallback() {
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
                blist = BitmapProcess.cutBitmap(cutCount, bitmapToPrint);
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
        myZyWell.WriteSendData(new TaskCallback() {
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

    public Bitmap convertGreyImg(Bitmap img) {
        int width = img.getWidth();
        int height = img.getHeight();

        int[] pixels = new int[width * height];

        img.getPixels(pixels, 0, width, 0, 0, width, height);

        // The arithmetic average of a grayscale image; a threshold
        double redSum = 0, greenSum = 0, blueSun = 0;
        double total = width * height;

        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                int grey = pixels[width * i + j];

                int red = ((grey & 0x00FF0000) >> 16);
                int green = ((grey & 0x0000FF00) >> 8);
                int blue = (grey & 0x000000FF);

                redSum += red;
                greenSum += green;
                blueSun += blue;
            }
        }
        int m = (int) (redSum / total);

        // Conversion monochrome diagram
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                int grey = pixels[width * i + j];

                int alpha1 = 0xFF << 24;
                int red = ((grey & 0x00FF0000) >> 16);
                int green = ((grey & 0x0000FF00) >> 8);
                int blue = (grey & 0x000000FF);

                if (red >= m) {
                    red = green = blue = 255;
                } else {
                    red = green = blue = 0;
                }
                grey = alpha1 | (red << 16) | (green << 8) | blue;
                pixels[width * i + j] = grey;
            }
        }
        Bitmap mBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
        mBitmap.setPixels(pixels, 0, width, 0, 0, width, height);
        return mBitmap;
    }



//    @ReactMethod
//    public void restartPrinter() {
//        sendDataToPrinter(new byte[]{27, 115, 66, 69, -110, -102, 1, 0, 95, 10});
//    }
}
