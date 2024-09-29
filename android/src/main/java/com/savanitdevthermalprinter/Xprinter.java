package com.savanitdevthermalprinter;

import static com.savanitdevthermalprinter.SavanitdevThermalPrinterModule.decodeBase64ToBitmap;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import net.posprinter.CPCLPrinter;
import net.posprinter.IDeviceConnection;
import net.posprinter.POSConnect;
import net.posprinter.POSConst;
import net.posprinter.POSPrinter;
import net.posprinter.TSPLConst;
import net.posprinter.TSPLPrinter;
import net.posprinter.ZPLPrinter;
import net.posprinter.model.AlgorithmType;
import net.posprinter.posprinterface.IStatusCallback;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

import zywell.posprinter.posprinterface.TaskCallback;

@ReactModule(name = Xprinter.NAME)
public class Xprinter extends ReactContextBaseJavaModule {
    public static final String NAME = "Xprinter";
    Context context;
    protected String[] mDataset;
    private IDeviceConnection[] connections = new IDeviceConnection[99];

    @NonNull
    @Override
    public String getName() {
        return NAME;
    }

    public Xprinter(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }

    @ReactMethod
    public void connectNetX(String ip, int index, Promise promise) {
        try {
            Log.d("TAG", "DEVICE_TYPE_ETHERNET: ");
            connections[index] = POSConnect.createDevice(POSConnect.DEVICE_TYPE_ETHERNET);
            connections[index].connect(ip, (code, msg) -> connectListener(index, code, promise));
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void connectUSBX(String ip, int index, Promise promise) {
        try {
            Log.d("TAG", "DEVICE_TYPE_USB: ");
            connections[index] = POSConnect.createDevice(POSConnect.DEVICE_TYPE_USB);
            connections[index].connect(ip, (code, msg) -> connectListener(index, code, promise));
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void connectBTX(String ip, int index, Promise promise) {
        try {
            Log.d("TAG", "DEVICE_TYPE_BLUETOOTH: ");
            connections[index] = POSConnect.createDevice(POSConnect.DEVICE_TYPE_BLUETOOTH);
            connections[index].connect(ip, (code, msg) -> connectListener(index, code, promise));
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void connectSERIAL(String ip, int index, Promise promise) {
        try {
            Log.d("TAG", "DEVICE_TYPE_SERIAL: ");
            connections[index] = POSConnect.createDevice(POSConnect.DEVICE_TYPE_SERIAL);
            connections[index].connect(ip, (code, msg) -> connectListener(index, code, promise));

        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void disConnectX(int index, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                connections[index].close();
                promise.resolve("DISCONNECT");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataX(int index, String encode, Promise promise) {
        try {
            Log.e("Log X ", String.valueOf(connections.equals(index)));
            if (connections[index].isConnect()) {
                POSPrinter printer = new POSPrinter(connections[index]);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).feedLine();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printImgZPL(int index, String base64String, int width, int x, int y, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connections[index]);
                printer.addStart()
                        .downloadBitmap(width, "SAMPLE.GRF", decodeBase64ToBitmap(base64String))
                        .addBitmap(x, y, "SAMPLE.GRF")
                        .addPrintCount(1)
                        .addEnd();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printImgTSPL(int index, String base64String, int width, int widthBmp, int height, int m, int n, int y,
            int x, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                TSPLPrinter printer = new TSPLPrinter(connections[index]);
                Bitmap bmp = decodeBase64ToBitmap(base64String);
                printer.sizeMm(width, height)
                        .gapMm(m, n)
                        .cls()
                        .bitmapCompression(x, y, TSPLConst.BMP_MODE_OVERWRITE_C, widthBmp, bmp, AlgorithmType.Threshold)
                        .print(1);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printImgCPCL(int index, String base64String, int width, int y, int x, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                CPCLPrinter printer = new CPCLPrinter(connections[index]);
                Bitmap bmp = decodeBase64ToBitmap(base64String);
                printer.addCGraphics(x, y, width, bmp, AlgorithmType.Threshold).addPrint();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printImgESCX(int index, String base64String, int width, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                POSPrinter printer = new POSPrinter(connections[index]);
                Bitmap bmp = decodeBase64ToBitmap(base64String);
                printer.printBitmap(bmp, POSConst.ALIGNMENT_CENTER, width).cutHalfAndFeed(1);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataZPL(int index, String encode, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connections[index]);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).addEnd();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void setPrintSpeed(int index, int speed, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connections[index]);
                printer.setPrintSpeed(speed);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void setPrintOrientation(int index, String orientation, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connections[index]);
                printer.setPrintOrientation(orientation);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void setPrintDensity(int index, int density, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connections[index]);
                printer.setPrintDensity(density);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void printerStatus(int index,int timeout, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connections[index]);
                printer.printerStatus(timeout, i -> promise.resolve(i));
            } else {
                promise.reject("ERROR", "FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataCPCL(int index, String encode, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                CPCLPrinter printer = new CPCLPrinter(connections[index]);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).addPrint();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataTSPL(int index, String encode, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                TSPLPrinter printer = new TSPLPrinter(connections[index]);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).print();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataESC(int index, String encode, Promise promise) {

        try {
            if (connections[index].isConnect()) {
                POSPrinter printer = new POSPrinter(connections[index]);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).feedLine();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void cutESCX(int index, Promise promise) {
        try {
            if (connections[index].isConnect()) {
                POSPrinter printer = new POSPrinter(connections[index]);
                printer.cutHalfAndFeed(1);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT_FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    private void connectList(int code, Promise promise) {
        if (code == POSConnect.CONNECT_SUCCESS) {
            Log.d("TAG", "CONNECT_SUCCESS: ");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                CompletableFuture.delayedExecutor(50, TimeUnit.MILLISECONDS).execute(() -> {
                    promise.resolve("CONNECTED");
                });
            }
        } else {
            // Log.d("TAG", "CONNECT_INTERRUPT: " + code);
            promise.reject("ERROR", "CONNECT_INTERRUPT");
        }
    }

    private void connectListener(int index, int code, Promise promise) {
        if (code == POSConnect.CONNECT_SUCCESS) {
            Log.d("ALERT", "CONNECT_SUCCESS: ");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                CompletableFuture.delayedExecutor(50, TimeUnit.MILLISECONDS).execute(() -> {
                    promise.resolve("CONNECTED");
                });
            }
        } else {
            // Log.d("TAG", "CONNECT_INTERRUPT: " + code);
            connections[index].close();
            promise.reject("ERROR", "CONNECT_INTERRUPT");
        }
    }

}
