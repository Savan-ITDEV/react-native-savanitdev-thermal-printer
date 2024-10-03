package com.savanitdevthermalprinter;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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
import net.posprinter.ZPLConst;
import net.posprinter.ZPLPrinter;
import net.posprinter.model.AlgorithmType;
import net.posprinter.posprinterface.IStatusCallback;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@ReactModule(name = Xprinter.NAME)
public class Xprinter extends ReactContextBaseJavaModule {
    public static final String NAME = "Xprinter";
    Context context;
    protected String[] mDataset;
    //    private IDeviceConnection[] connections = new IDeviceConnection[99];
    // Using HashMap to store connections by IP address (or any string key)
    private final Map<String, IDeviceConnection> connections = new HashMap<>();

    @NonNull
    @Override
    public String getName() {
        return NAME;
    }

    public Xprinter(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
        POSConnect.init(reactContext);
        Log.e("Xprinter", "Start init");
    }

    @ReactMethod
    public void connectMultiXPrinter(String address, int portType, Promise promise) {
        try {
            Log.d("TAG", "DEVICE_TYPE_ETHERNET: ");
            int type = 3;
            if (portType == 1) {
                type = POSConnect.DEVICE_TYPE_USB;
            } else if (portType == 2) {
                type = POSConnect.DEVICE_TYPE_BLUETOOTH;
            } else if (portType == 4) {
                type = POSConnect.DEVICE_TYPE_SERIAL;
            } else {
                type = POSConnect.DEVICE_TYPE_ETHERNET;
            }

            IDeviceConnection connected = connections.get(address);
            if (connected != null && connected.isConnect()) {
                Log.d("TAG", "connected: ");
                promise.resolve("CONNECTED");
            }else{
                Log.d("TAG", "NEW connect: ");
                removeConnection(address);
                // Create the device connection and use the IP address as the key
                IDeviceConnection connection = POSConnect.createDevice(type);
                connections.put(address, connection);  // Store the connection with IP as key
                // Attempt to connect the device and use a callback listener
                connection.connect(address, (code, msg) -> connectListener(address, code, promise));
         }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void disConnectXPrinter(String address, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                removeConnection(address);
                promise.resolve("DISCONNECT");
            } else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    public void removeConnection(String ip) {
        // Check if the connection exists for the given IP
        if (connections.containsKey(ip)) {
            // Retrieve and close the connection before removing it
            IDeviceConnection connection = connections.get(ip);
            if (connection != null) {
                connection.close();  // Close the connection safely
            }

            // Remove the connection from the map
            connections.remove(ip);
            Log.d("TAG", "Connection removed for IP: " + ip);
        } else {
            Log.d("TAG", "No connection found for IP: " + ip);
        }
    }

    @ReactMethod
    public void printImgZPL(String address, String base64String, int width,int printCount, int x, int y, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                    ZPLPrinter printer = new ZPLPrinter(connection);
                    printer.addStart()
                             .downloadBitmap(width, "SAMPLE.GRF", decodeBase64ToBitmap(base64String))
                             .addBitmap(x, y, "SAMPLE.GRF")
                             .addPrintCount(printCount)
                             .addEnd();
                    promise.resolve("SUCCESS");
                } else {
                    promise.reject("ERROR", "DISCONNECT");
                }

            } else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    public  Bitmap decodeBase64ToBitmap(String base64String) {
        byte[] decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
    }

    @ReactMethod
    public void printImgTSPL(String address, String base64String, int width, int widthBmp, int height, int m, int n, int y,
                             int x, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                    TSPLPrinter printer = new TSPLPrinter(connection);
                    Bitmap bmp = decodeBase64ToBitmap(base64String);
                    printer.sizeMm(width, height)
                            .gapMm(m, n)
                            .cls()
                            .bitmapCompression(x, y, TSPLConst.BMP_MODE_OVERWRITE_C, widthBmp, bmp, AlgorithmType.Threshold)
                            .print(1);
                    promise.resolve("SUCCESS");
                } else {
                    promise.reject("ERROR", "DISCONNECT");
                }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }

        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printImgCPCL(String address, String base64String, int width, int y, int x, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                CPCLPrinter printer = new CPCLPrinter(connection);
                Bitmap bmp = decodeBase64ToBitmap(base64String);
                printer.addCGraphics(x, y, width, bmp, AlgorithmType.Threshold).addPrint();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {

            promise.reject("ERROR", e.toString());
        }
    }
    public void statusXprinter(POSPrinter printer, Promise promise) {

        printer.printerStatus(status -> {
            // Handle the received status here
            String msg;
            switch (status) {
                case 0:
                    msg = "STS_NORMAL";
                    promise.resolve(msg);
                    break;
                case 8:
                    msg = "STS_COVEROPEN";
                    promise.resolve(msg);
                    break;
                case 16:
                    msg = "STS_PAPEREMPTY";
                    promise.resolve(msg);
                    break;
                case 32:
                    msg = "STS_PRESS_FEED";
                    promise.resolve(msg);
                    break;
                case 64:
                    promise.reject("ERROR", "PRINT_FAIL");
                    msg = "Printer error";
                    break;
                default:
                    msg = "UNKNOWN";
                    if(status > 0 ){
                        promise.resolve(msg);
                    }else if(status == -4){
                        promise.resolve(msg);
                    }
                    else{
                        promise.reject("ERROR", "PRINT_FAIL");
                    }
                    Log.e("STATUS PRINT", String.valueOf(status));
//                    promise.reject("ERROR", "PRINT_FAIL");
                    break;
            }


            // You can now display the message
        });
    }
    @ReactMethod
    public void printRawDataESC(String address, String encode, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null && connection.isConnect()) {
                POSPrinter printer = new POSPrinter(connection);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes);
                statusXprinter(printer,promise);
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }

        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printImgESCX(String address, String base64String, int width, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null && connection.isConnect()) {
                        POSPrinter printer = new POSPrinter(connection);
                        Bitmap bmp = decodeBase64ToBitmap(base64String);
                        printer.printBitmap(bmp, POSConst.ALIGNMENT_CENTER, width).cutHalfAndFeed(1);

                    statusXprinter(printer,promise);

            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataZPL(String address, String encode, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connection);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).addEnd();

                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {

            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void setPrintSpeed(String address, int speed, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connection);
                printer.setPrintSpeed(speed);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void setPrintOrientation(String address, String orientation, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connection);
                printer.setPrintOrientation(orientation);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "FAIL");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void setPrintDensity(String address, int density, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connection);
                printer.setPrintDensity(density);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }
    @ReactMethod
    public void printerStatus(String address,int timeout, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                ZPLPrinter printer = new ZPLPrinter(connection);
                printer.printerStatus(timeout, i -> promise.resolve(i));
            } else {
                promise.reject("ERROR", "FAIL");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataCPCL(String address, String encode, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                CPCLPrinter printer = new CPCLPrinter(connection);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).addPrint();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataTSPL(String address, String encode, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                TSPLPrinter printer = new TSPLPrinter(connection);
                byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
                printer.sendData(bytes).print();
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }



    @ReactMethod
    public void cutESCX(String address, Promise promise) {
        try {
            IDeviceConnection connection = connections.get(address);
            if (connection != null) {
                if (connection.isConnect()) {
                POSPrinter printer = new POSPrinter(connection);
                printer.cutHalfAndFeed(1);
                promise.resolve("SUCCESS");
            } else {
                promise.reject("ERROR", "DISCONNECT");
            }
            }else {
                promise.reject("ERROR", "GET_ID_FAIL");
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
        }
    }

    private void connectListener(String address, int code, Promise promise) {
        IDeviceConnection connection = connections.get(address);
        if (connection != null && connection.isConnect()) {

                Log.d("ALERT", "CONNECT_SUCCESS: ");
                promise.resolve("CONNECTED");

        } else {
                Log.d("TAG", "CONNECT_INTERRUPT: " + code);
                // Reject the promise with an error
                promise.reject("ERROR", "DISCONNECT");
            }
        }



        

}


