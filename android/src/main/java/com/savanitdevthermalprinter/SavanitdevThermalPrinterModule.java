package com.savanitdevthermalprinter;

import static android.app.PendingIntent.FLAG_IMMUTABLE;
import static android.content.Context.BIND_AUTO_CREATE;

import static zywell.posprinter.utils.StringUtils.byteMerger;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketTimeoutException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

import zywell.posprinter.posprinterface.IMyBinder;
import zywell.posprinter.posprinterface.ProcessData;
import zywell.posprinter.posprinterface.TaskCallback;
import zywell.posprinter.service.PosprinterService;
import zywell.posprinter.utils.BitmapProcess;
import zywell.posprinter.utils.BitmapToByteData;
import zywell.posprinter.utils.DataForSendToPrinterPos58;
import zywell.posprinter.utils.DataForSendToPrinterPos80;
import zywell.posprinter.utils.PosPrinterDev;
import zywell.posprinter.utils.RoundQueue;

import net.posprinter.IDeviceConnection;
import net.posprinter.POSConnect;
import net.posprinter.POSPrinter;
import net.posprinter.ZPLPrinter;

@ReactModule(name = SavanitdevThermalPrinterModule.NAME)
public class SavanitdevThermalPrinterModule extends ReactContextBaseJavaModule {
    public static final String NAME = "SavanitdevThermalPrinter";
    List<byte[]> setPrinter = new ArrayList<>();
    private List<String> usbList, usblist;
    private BluetoothAdapter bluetoothAdapter;
    private DeviceReceiver BtReciever;
    public static IMyBinder myBinder;
    public static boolean ISCONNECT = false;
    public static String address = "";
    UsbManager mUsbManager;
    protected String[] mDataset;

    private IDeviceConnection[] connections = new IDeviceConnection[99];
    private static final String ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION";
    Context context;

    ServiceConnection mSerconnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            myBinder = (IMyBinder) service;
            Log.e("myBinder", "connect");
            // Toast toast = Toast.makeText(context, "connect", Toast.LENGTH_SHORT);
            // toast.show();
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.e("myBinder", "disconnect");
            myBinder = null;
            // Toast toast = Toast.makeText(context, "disconnect", Toast.LENGTH_SHORT);
            // toast.show();
        }
    };

    public SavanitdevThermalPrinterModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
        try {
            Log.e("myBinder", "initial printer");
            Intent intent = new Intent(context, PosprinterService.class);
            context.bindService(intent, mSerconnection, BIND_AUTO_CREATE);
            POSConnect.init(reactContext);
        } catch (Exception exe) {
            Log.d("myBinder ERROR", "Exception--: " + exe);
        }
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @ReactMethod
    private void onCreate(Promise promise) {
        try {
            Intent intent = new Intent(context, PosprinterService.class);
            context.bindService(intent, mSerconnection, BIND_AUTO_CREATE);
        } catch (Exception exe) {
            Log.d("TAG", "Exception--: " + exe);
            promise.reject("ERROR", exe.toString());
        }
    }
    // Xprinter

    @ReactMethod
    public void printRawDataX(int index, String encode, Promise promise) {
        try {
            POSPrinter printer = new POSPrinter(connections[index]);
            byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
            printer.sendData(bytes).feedLine();
            promise.resolve("SUCCESS");
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
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
    public void disConnectX(String ip, int index, Promise promise) {
        try {
            connections[index].close();
            promise.resolve("DISCONNECT");
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("ERROR", e.toString());
        }
    }

    @ReactMethod
    public void printRawDataZPL(String ip, int index, String encode, Promise promise) {
        try {
            ZPLPrinter printer = new ZPLPrinter(connections[index]);
            byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
            printer.sendData(bytes).addEnd();
            promise.resolve("SUCCESS");
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
            Log.d("TAG", "CONNECT_INTERRUPT: " + code);
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
            Log.d("TAG", "CONNECT_INTERRUPT: " + code);
            connections[index].close();
            promise.reject("ERROR", "CONNECT_INTERRUPT");
        }
    }

    // Xprinter

    @ReactMethod
    public void startQuickDiscovery(int timeout, Promise promise) {
        new Thread() {
            public void run() {
                DatagramSocket socket = null;
                try {
                    // Prepare the UDP socket
                    socket = new DatagramSocket(5001);
                    socket.setSoTimeout(timeout); // 1-second timeout for quick discovery
                    byte[] sendData = "ZY0001FIND".getBytes();

                    // Send broadcast UDP packet
                    DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length,
                            InetAddress.getByName("255.255.255.255"), 1460);
                    socket.send(sendPacket);

                    // Prepare buffer for receiving data
                    byte[] receiveData = new byte[1024];
                    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);

                    WritableArray printersArray = Arguments.createArray();
                    boolean printerFound = false;

                    // Perform multiple quick checks (e.g., 5 tries of 1 second each)
                    for (int i = 0; i < 5; i++) {
                        try {
                            socket.receive(receivePacket); // Listen for response
                            String receivedString = new String(receivePacket.getData(), 0, receivePacket.getLength());
                            WritableMap printerInfo = Arguments.createMap();
                            printerInfo.putString("ipAddress", receivePacket.getAddress().toString());
                            printerInfo.putString("message", receivedString);
                            printersArray.pushMap(printerInfo);

                            // Exit early if a printer is found
                            printerFound = true;
                            break;

                        } catch (SocketTimeoutException e) {
                            // Timeout for this iteration, continue to next
                        } catch (IOException e) {
                            Log.e("PrinterDiscovery", "Error receiving packet", e);
                            promise.reject("IO_EXCEPTION", e);
                            return;
                        }
                    }

                    // If a printer was found, resolve with the list
                    if (printerFound) {
                        Handler handler = new Handler(Looper.getMainLooper());
                        final WritableArray finalPrintersArray = printersArray;
                        handler.post(() -> promise.resolve(finalPrintersArray));
                    } else {
                        // No printer found, return empty array
                        promise.resolve(printersArray);
                    }

                } catch (IOException e) {
                    Log.e("PrinterDiscovery", "Error sending packet", e);
                    promise.reject("DISCOVERY_ERROR", e);
                } finally {
                    if (socket != null && !socket.isClosed()) {
                        socket.close();
                    }
                }
            }
        }.start();
    }

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
    private void getPrinterInfoList(Promise promise) {
        try {
            String data = String.valueOf(myBinder.GetPrinterInfoList().toString());
            promise.resolve(data);
        } catch (Exception e) {
            promise.reject("ERROR", e.toString());
            throw new RuntimeException(e);
        }
    }

    @ReactMethod
    public void removeMulti(String printerName, Promise promise) {
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
    public void connectMulti(String address, int portType, final Promise promise) {
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
    public void printImgMulti(String printerName, String base64String, int width, Promise promise) {
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
                        final Bitmap bitmapToPrint = convertGreyImg(bitmap1);
                        list.add(DataForSendToPrinterPos80.initializePrinter());
                        list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmapToPrint,
                                BitmapToByteData.BmpType.Dithering,
                                BitmapToByteData.AlignType.Center, width));
                        list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
                        return list;
                    }
                });
            } else {
                promise.reject(new Exception("CONNECT_FAIL_IP_NULL"));
            }
        } else {
            promise.reject(new Exception("CONNECT_BLE_FAIL_IP_NULL"));
        }
    }

    @ReactMethod
    public void printRawDataMulti(String printerName, String base64String, Promise promise) {
        if (printerName != null) {
            boolean isValidate = findPrinterByName(printerName);
            Log.e("isValidate", String.valueOf(isValidate));
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
                promise.reject(new Exception("CONNECT_FAIL_IP_NULL"));
            }
        } else {
            promise.reject(new Exception("CONNECT_FAIL"));
        }
    }

    @ReactMethod
    private void pingDevice(String ip, int timeout, Promise promise) {
        try {
            NetworkUtils.fastPingAndGetNetworkSpeed(ip, timeout, promise);
        } catch (Exception exe) {
            Log.d("TAG", "Exception--: " + exe);
            promise.reject("ERROR", exe.toString());
        }
    }

    @ReactMethod
    public void printPicMulti(String address, String imagePath,
            final ReadableMap options, final Promise promise) {
        Uri imageUri = Uri.parse(imagePath);
        String realPath = imageUri.getPath();

        int size = options.getInt("size");
        int width = options.getInt("width");

        final boolean isDisconnect;
        if (options.hasKey("is_disconnect")) {
            isDisconnect = options.getBoolean("is_disconnect");
        } else {
            isDisconnect = false;
        }

        final boolean isCutPaper;
        if (options.hasKey("cut_paper")) {
            isCutPaper = options.getBoolean("cut_paper");
        } else {
            isCutPaper = true;
        }

        String mode;
        if (options.hasKey("mode")) {
            mode = options.getString("mode");
        } else {
            mode = "THERMAL";
        }

        final Bitmap bitmap = BitmapFactory.decodeFile(realPath);

    }

    @ReactMethod
    private void printImgByte(String base64String, int width, Promise promise) {
        if (ISCONNECT) {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("print done");
                }

                @Override
                public void OnFailed() {
                    promise.reject("ERROR", "OnFailed printImg");
                    // disConnectNet(promise);
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmap1, BitmapToByteData.BmpType.Dithering,
                            BitmapToByteData.AlignType.Center, width));
                    return list;
                }
            });
        } else {
            promise.reject("0", "please connect device first!");
        }
    }

    @ReactMethod
    private void printImgWithTimeout(String base64String, int size, boolean isCutPaper, int width, int cutCount,
            int timeout, Promise promise) {

        if (ISCONNECT) {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), width);
            final Bitmap bitmapToPrint = convertGreyImg(bitmap1);
            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("SEND_SUCCESS");
                    if (ISCONNECT) {
                        TimerTask task = new TimerTask() {
                            @Override
                            public void run() {
                                disConnectNet();
                            }
                        };
                        Timer timer = new Timer();
                        timer.schedule(task, timeout);
                    }
                }

                @Override
                public void OnFailed() {
                    promise.reject("ERROR", "OnFailed printImg");
                    // disConnectNet(promise);
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    if (size == 58) {
                        list.add(DataForSendToPrinterPos58.initializePrinter());
                    } else {
                        list.add(DataForSendToPrinterPos80.initializePrinter());
                    }
                    List<Bitmap> blist = new ArrayList<>();
                    blist = BitmapProcess.cutBitmap(cutCount, bitmapToPrint);
                    for (int i = 0; i < blist.size(); i++) {
                        if (size == 58) {
                            list.add(DataForSendToPrinterPos58.printRasterBmp(
                                    0, blist.get(i), BitmapToByteData.BmpType.Dithering,
                                    BitmapToByteData.AlignType.Left, width));
                        } else {
                            list.add(DataForSendToPrinterPos80.printRasterBmp(
                                    0, blist.get(i), BitmapToByteData.BmpType.Dithering,
                                    BitmapToByteData.AlignType.Left, width));
                        }
                    }

                    if (size == 58 && isCutPaper) {
                        list.add(DataForSendToPrinterPos58.printAndFeedLine());
                    } else if (isCutPaper) {
                        list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    }

                    if (size == 80 && isCutPaper) {
                        list.add(
                                DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(
                                        0x42, 0x66));
                    }
                    return list;
                }
            });
        } else {
            promise.reject("0", "please connect device first!");
        }
    }

    // @ReactMethod
    // public void StopMonitorPrinter(Promise promise) {
    // if (ISCONNECT == true) {
    // myBinder.StopMonitorPrinter();
    // promise.resolve("SUCCESS");
    // } else {
    // promise.reject(new Exception("GetPrinterStatus Fail"));
    // ISCONNECT = false;
    // }
    // }
    //
    // @ReactMethod
    // public void GetPrinterStatus(Promise promise) {
    // if (ISCONNECT == true) {
    //
    // String status = myBinder.GetPrinterStatus().toString();
    // promise.resolve(status);
    // } else {
    // promise.reject(new Exception("GetPrinterStatus Fail"));
    // ISCONNECT = false;
    // }
    // }
    //
    // @ReactMethod
    // public void GetPrinterStatusMulti(String printerName, Promise promise) {
    // if (ISCONNECT == true) {
    // String status = String.valueOf(myBinder.GetPrinterStatus(printerName));
    // promise.resolve(status);
    // } else {
    // promise.reject(new Exception("GetPrinterStatus Fail"));
    // ISCONNECT = false;
    // }
    // }

    @ReactMethod
    public void ClearBuffer(Promise promise) {
        if (ISCONNECT == true) {
            myBinder.ClearBuffer();
            promise.resolve("true");
        } else {
            promise.reject(new Exception("ClearBuffer_FAIL"));
            ISCONNECT = false;
        }
    }

    @ReactMethod
    public void ReadBuffer(Promise promise) {
        RoundQueue<byte[]> queue = myBinder.ReadBuffer();
        if (queue != null && queue.realSize() > 0) {
            // The queue is not empty
            WritableMap result = Arguments.createMap();
            result.putInt("queueSize", queue.realSize());
            promise.resolve(result);
        } else {
            // The queue is empty
            promise.resolve(null);
        }
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

    // function single connection
    @ReactMethod
    private void printLangPrinter(Promise promise) {

        if (ISCONNECT) {
            sendDataToPrinter(new byte[] { 27, 64, 28, 46, 27, 33, 0, -123, -122, -121, -120, -119, -118, -117, -116,
                    -115, -114, -113, -112, -111, -110, -109, -108, -107, -106, -105, -104, -103, -102, -101, -100, -99,
                    -98, -97, -96, -95, -94, -93, -92, -91, -90, -89, -88, -87, -86, -85, -84, -83, -82, -81, -80, -79,
                    -78, -77, -76, -75, -74, -73, -72, -71, -70, -69, -68, -67, -66, -65, -64, -63, -62, -61, -60, -59,
                    -58, -57, -56, -55, -54, -53, -52, -51, -50, -49, -48, -47, -46, -45, -44, -43, -42, -41, -40, -39,
                    -38, -37, -36, -35, -34, -33, -32, -31, -30, -29, -28, -27, -26, -25, -24, -23, -22, -21, -20, -19,
                    -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 0, 0, 0, 0, 10,
                    27, 64, 29, 86, 65, 72, 28, 38, 0 });
            promise.resolve("done");
        } else {
            promise.reject("", "please connect printer!");
        }
    }

    @ReactMethod
    private void setLang(String codepage, Promise promise) {

        if (ISCONNECT) {
            byte codepageByte = Byte.parseByte(codepage);
            sendDataToPrinter(
                    byteMerger(new byte[] { 31, 27, 31, -1 }, new byte[] { (byte) codepageByte, 10, 0 }));
            promise.resolve("done");
        } else {
            promise.reject("", "please connect printer!");
        }
    }

    @ReactMethod
    private void cancelChinese() {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
        } else {
            if (ISCONNECT) {
                // cancel -> 8 : use -> 0
                sendDataToPrinter(new byte[] { 31, 27, 31, -65, 8, 0 });
            }
        }
    }

    @ReactMethod
    private void printBitmapBLE(String base64String, int w1, int w2, int isBLE, Promise promise) {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
            promise.reject("turnoff");

        } else {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), w1);

            if (ISCONNECT) {
                myBinder.WriteSendData(new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        promise.resolve("SUCCESS");

                    }

                    @Override
                    public void OnFailed() {
                        promise.reject(new Exception("SEND_ERROR"));
                        disConnectNet();
                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {
                        List<byte[]> list = new ArrayList<>();
                        list.add(DataForSendToPrinterPos80.initializePrinter());
                        List<Bitmap> blist = new ArrayList<>();
                        blist = BitmapProcess.cutBitmap(w1, bitmap1);
                        for (int i = 0; i < blist.size(); i++) {
                            list.add(DataForSendToPrinterPos80.printRasterBmp(0, blist.get(i),
                                    BitmapToByteData.BmpType.Dithering, BitmapToByteData.AlignType.Right, w2));
                            // list.add(DataForSendToPrinterPos80.printRasterBmp(0,blist.get(i),
                            // BitmapToByteData.BmpType.Threshold, BitmapToByteData.AlignType.Center,w2));
                        }
                        list.add(DataForSendToPrinterPos80.printAndFeedLine());

                        if (isBLE == 0) {
                            list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
                        }

                        return list;
                    }
                });
            } else {
                promise.reject("", "OnFailed print img");
                disConnectBT(promise);

            }
        }
    }

    @ReactMethod
    private void connectBT(String macAddress, Promise promise) {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
            promise.reject("turnoff");

        } else {
            if (macAddress.equals(null) || macAddress.equals("")) {
                promise.reject("Error connect BTE");
            } else {
                if (ISCONNECT == true && address == macAddress) {
                    promise.resolve("connect BTE success");
                } else {
                    myBinder.ConnectBtPort(macAddress, new TaskCallback() {
                        @Override
                        public void OnSucceed() {
                            address = macAddress;
                            ISCONNECT = true;
                            promise.resolve("connect BTE success");
                        }

                        @Override
                        public void OnFailed() {
                            address = "";
                            disConnectBT(promise);
                            promise.reject("Error connect BTE");

                        }
                    });
                }

            }
        }
    }

    @ReactMethod
    private void disConnectBT(Promise promise) {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
            promise.reject("turnoff");

        } else {
            myBinder.DisconnectCurrentPort(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    address = "";
                    ISCONNECT = false;
                    promise.resolve("disconnect");
                }

                @Override
                public void OnFailed() {
                    ISCONNECT = true;
                    promise.reject("0", "OnFailed disConnectBT");
                }
            });

        }
    }

    @ReactMethod
    private void printRawData(String encode, Promise promise) {
        byte[] bytes = Base64.decode(encode, Base64.DEFAULT);
        myBinder.Write(bytes, new TaskCallback() {
            @Override
            public void OnSucceed() {
                promise.resolve("success print raw");
            }

            @Override
            public void OnFailed() {
                promise.reject("error print raw");
            }
        });
    }

    @SuppressLint("MissingPermission")
    @ReactMethod
    private void findAvailableDevice(Promise promise) {
        try {
            bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            if (!bluetoothAdapter.isEnabled()) {
                promise.reject("turnoff");

            } else {

                if (!bluetoothAdapter.isDiscovering()) {
                    bluetoothAdapter.startDiscovery();
                }

                IntentFilter filterStart = new IntentFilter(BluetoothDevice.ACTION_FOUND);
                IntentFilter filterEnd = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.registerReceiver(BtReciever, filterStart, Context.RECEIVER_EXPORTED);
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.registerReceiver(BtReciever, filterEnd, Context.RECEIVER_EXPORTED);
                }
                Set<BluetoothDevice> device = bluetoothAdapter.getBondedDevices();

                WritableMap result = Arguments.createMap();
                for (Iterator<BluetoothDevice> it = device.iterator(); it.hasNext();) {
                    BluetoothDevice btd = it.next();
                    // Log.d("TAG==========>", btd.getName()+','+btd.getAddress());
                    // result.putString(btd.getName(), btd.getAddress());
                    result.putString(btd.getAddress(), btd.getName() + ',' + btd.getAddress());
                }
                promise.resolve(result);
            }
        } catch (Exception exe) {
            Log.d("TAG", "Exception--: " + exe);
            promise.reject(exe);
        }
    }

    private void doYourOpenUsbDevice(UsbDevice usbDevice) {
        // now follow line will NOT show: User has not given permission to device
        // UsbDevice
        UsbDeviceConnection connection = mUsbManager.openDevice(usbDevice);
        // add your operation code here
    }

    private void afterGetUsbPermission(UsbDevice usbDevice) {
        // call method to set up device communication
        // Toast.makeText(this, String.valueOf("Got permission for usb device: " +
        // usbDevice), Toast.LENGTH_LONG).show();
        // Toast.makeText(this, String.valueOf("Found USB device: VID=" +
        // usbDevice.getVendorId() + " PID=" + usbDevice.getProductId()),
        // Toast.LENGTH_LONG).show();

        doYourOpenUsbDevice(usbDevice);
    }

    private final BroadcastReceiver mUsbPermissionActionReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (ACTION_USB_PERMISSION.equals(action)) {
                synchronized (this) {
                    UsbDevice usbDevice = (UsbDevice) intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        // user choose YES for your previously popup window asking for grant perssion
                        // for this usb device
                        if (null != usbDevice) {
                            afterGetUsbPermission(usbDevice);
                        }
                    } else {
                        // user choose NO for your previously popup window asking for grant perssion for
                        // this usb device
                        Toast.makeText(context, String.valueOf("Permission denied for device" + usbDevice),
                                Toast.LENGTH_LONG).show();
                    }
                }
            }
        }
    };

    @ReactMethod
    private void tryGetUsbPermission() {
        // mUsbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
        mUsbManager = (UsbManager) context.getSystemService(Context.USB_SERVICE);

        IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.registerReceiver(mUsbPermissionActionReceiver, filter, Context.RECEIVER_EXPORTED);
        }
        PendingIntent mPermissionIntent = PendingIntent.getBroadcast(context, 0, new Intent(ACTION_USB_PERMISSION),
                FLAG_IMMUTABLE);

        // here do emulation to ask all connected usb device for permission
        for (final UsbDevice usbDevice : mUsbManager.getDeviceList().values()) {
            // add some conditional check if necessary
            // if(isWeCaredUsbDevice(usbDevice)){
            if (mUsbManager.hasPermission(usbDevice)) {
                // if has already got permission, just goto connect it
                // that means: user has choose yes for your previously popup window asking for
                // grant perssion for this usb device
                // and also choose option: not ask again

                // afterGetUsbPermission(usbDevice);
            } else {
                // this line will let android popup window, ask user whether to allow this app
                // to have permission to operate this usb device
                mUsbManager.requestPermission(usbDevice, mPermissionIntent);
            }
            // }
        }
    }

    public static Bitmap decodeBase64ToBitmap(String base64String) {
        byte[] decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
    }

    @ReactMethod
    private void disConnectNet() {
        if (ISCONNECT) {
            myBinder.DisconnectCurrentPort(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    ISCONNECT = false;
                }

                @Override
                public void OnFailed() {
                    ISCONNECT = true;

                }
            });
        }

    }

    @ReactMethod
    private void printImg(String base64String, int w1, int w2, int isBLE, Promise promise) {
        if (ISCONNECT) {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), w1);
            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("print done");
                }

                @Override
                public void OnFailed() {
                    promise.reject("ERROR", "OnFailed printImg");
                    // disConnectNet(promise);
                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmap1, BitmapToByteData.BmpType.Dithering,
                            BitmapToByteData.AlignType.Right, w2));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());

                    if (isBLE == 0) {
                        list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
                    }

                    return list;
                }
            });
        } else {
            promise.reject("0", "please connect device frist!");
        }
    }

    @ReactMethod
    private void connectNet(String ip, Promise promise) {
        if (ip != null) {
            if (ISCONNECT) {
                myBinder.DisconnectCurrentPort(new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        ISCONNECT = false;
                        connectNet(ip, promise);
                        // promise.resolve(Boolean.toString(ISCONNECT));
                    }

                    @Override
                    public void OnFailed() {
                        ISCONNECT = true;
                        promise.reject(Boolean.toString(true));
                    }
                });
            } else {
                myBinder.ConnectNetPort(ip, 9100, new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        ISCONNECT = true;
                        promise.resolve(Boolean.toString(true));
                    }

                    @Override
                    public void OnFailed() {
                        ISCONNECT = false;
                        promise.reject(Boolean.toString(false));

                    }
                });
            }
        } else {
            promise.reject(Boolean.toString(false));
        }
    }

    @ReactMethod
    private void getUSB(Promise promise) {
        try {
            usbList = PosPrinterDev.GetUsbPathNames(context);
            if (usbList == null) {
                usbList = new ArrayList<>();
            }
            usblist = usbList;

            promise.resolve(usblist.toString());
        } catch (Exception exe) {
            Log.d("TAG", "Exception--: " + exe);
            promise.reject("get USB error");
        }
    }

    @ReactMethod
    private void connectUSB(String usbAddress, Promise promise) {
        if (usbAddress != null) {
            myBinder.ConnectUsbPort(context.getApplicationContext(), usbAddress, new TaskCallback() {
                @Override
                public void OnSucceed() {
                    ISCONNECT = true;
                    promise.resolve(Boolean.toString(ISCONNECT));
                }

                @Override
                public void OnFailed() {
                    ISCONNECT = false;
                    promise.reject(Boolean.toString(ISCONNECT));

                }
            });

        } else {
            promise.reject("No usbAddress");
        }
    }

    @ReactMethod
    private void printText(Promise promise) {
        if (ISCONNECT) {
            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {

                    // disConnectNet();
                    promise.resolve("Done");
                }

                @Override
                public void OnFailed() {

                    promise.reject("error", "printText fail!");
                    // disConnectNet();

                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    return setPrinter;
                }
            });
        } else {
            promise.reject("error", "print ISCONNECT  false");
            // disConnectNet();
        }
    }

    @ReactMethod
    private void getLangModel() {
        if (ISCONNECT) {
            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {

                }

                @Override
                public void OnFailed() {

                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    ArrayList arrayList = new ArrayList();
                    arrayList.add(new byte[] { 31, 27, 31, 103 });
                    arrayList.add(DataForSendToPrinterPos80.printAndFeedLine());
                    return arrayList;
                }
            });
        }
    }

    public void sendDataToPrinter(byte[] bArr) {
        if (ISCONNECT) {
            myBinder.Write(bArr, new TaskCallback() {
                public void OnFailed() {
                    Log.e("OnFailed: ", "");

                }

                public void OnSucceed() {
                    Log.e("OnSucceed: ", "");

                }
            });
        } else {
            Log.e("OnFailed: CONNECT", "");
        }
    }

    @ReactMethod
    public void getByteArrayList(Promise promise) {
        try {
            WritableArray writableArray = Arguments.createArray();
            for (byte[] byteArray : setPrinter) {
                String base64String = Base64.encodeToString(byteArray, Base64.DEFAULT);
                writableArray.pushString(base64String);
            }

            promise.resolve(writableArray);
        } catch (Exception e) {
            promise.reject("Error", e);
        }
    }

    @ReactMethod
    public void clearPaper(Promise promise) {
        setPrinter.clear();
        if (setPrinter.size() == 0) {
            promise.resolve("0");
        }
    }

    @ReactMethod
    public void getEncode(String base64String) {
        byte[] bytes = Base64.decode(base64String, Base64.DEFAULT);
        setPrinter.add(bytes);
    }

    @ReactMethod
    public void initializeText() {
        setPrinter.add(DataForSendToPrinterPos80.initializePrinter());
    }

    @ReactMethod
    public void cut() {
        setPrinter.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
    }

    @ReactMethod
    public void printAndFeedLine() {
        setPrinter.add(DataForSendToPrinterPos80.printAndFeedLine());
    }

    @ReactMethod
    public void CancelChineseCharModel() {
        setPrinter.add(DataForSendToPrinterPos80.CancelChineseCharModel());
    }

    @ReactMethod
    public void selectAlignment(int n) {
        // type : 0 = left , 1 = : center , right : 2
        setPrinter.add(DataForSendToPrinterPos80.selectAlignment(n));
    }

    @ReactMethod
    public void text(String text, String charset) {
        // setPrinter.add(strTobytes(text, charset));
    }

    @ReactMethod
    public void selectCharacterSize(int n) {
        setPrinter.add(DataForSendToPrinterPos80.selectCharacterSize(n));
    }

    @ReactMethod
    public void selectOrCancelBoldModel(int n) {
        setPrinter.add(DataForSendToPrinterPos80.selectOrCancelBoldModel(n));
    }

    @ReactMethod
    public void selectCharacterCodePage(int n) {
        setPrinter.add(DataForSendToPrinterPos80.selectCharacterCodePage(n));
    }

    @ReactMethod
    public void selectInternationalCharacterSets(int n) {
        setPrinter.add(DataForSendToPrinterPos80.selectInternationalCharacterSets(n));
    }

    @ReactMethod
    public void setAbsolutePrintPosition(int n, int m) {
        setPrinter.add(DataForSendToPrinterPos80.setAbsolutePrintPosition(n, m));
    }

    @ReactMethod
    public void setImg(String base64String, int w1) {
        final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), w1);
        List<Bitmap> blist = new ArrayList<>();
        blist = BitmapProcess.cutBitmap(5, bitmap1);
        for (int i = 0; i < blist.size(); i++) {
            setPrinter.add(DataForSendToPrinterPos80.printRasterBmp(0, blist.get(i), BitmapToByteData.BmpType.Dithering,
                    BitmapToByteData.AlignType.Center, w1));
        }
    }

    @ReactMethod
    public void line(int length) {
        // String line = new String(new char[length]).replace("\0", ".");
        // // Convert the string to bytes using the existing method
        // byte[] lineBytes = strTobytes(line);
        // // Add a carriage return and line feed to move to the next line
        // byte[] newline = new byte[] { 13, 10 }; // CR LF
        // // Combine the line bytes with the newline bytes
        // byte[] data = byteMerger(lineBytes, newline);
        //
        // setPrinter.add(data);
    }

    @ReactMethod
    public void line2(int length) {
        // String line = new String(new char[length]).replace("\0", "-");
        //
        // // Convert the string to bytes using the existing method
        // byte[] lineBytes = strTobytes(line);
        //
        // // Add a carriage return and line feed to move to the next line
        // byte[] newline = new byte[] { 13, 10 }; // CR LF
        //
        // // Combine the line bytes with the newline bytes
        // byte[] data = byteMerger(lineBytes, newline);
        //
        // setPrinter.add(data);
    }

    @ReactMethod
    public void line3(int length) {
        String line = new String(new char[length]).replace("\0", "=");

        // // Convert the string to bytes using the existing method
        // byte[] lineBytes = strTobytes(line);
        //
        // // Add a carriage return and line feed to move to the next line
        // byte[] newline = new byte[] { 13, 10 }; // CR LF
        //
        // // Combine the line bytes with the newline bytes
        // byte[] data = byteMerger(lineBytes, newline);
        //
        // setPrinter.add(data);
    }

}
