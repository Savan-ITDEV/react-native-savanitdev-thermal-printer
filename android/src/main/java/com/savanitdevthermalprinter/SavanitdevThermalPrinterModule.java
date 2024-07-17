package com.savanitdevthermalprinter;

import static android.app.PendingIntent.FLAG_IMMUTABLE;
import static android.content.Context.BIND_AUTO_CREATE;

import android.Manifest;
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
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbManager;
import android.os.IBinder;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import androidx.annotation.NonNull;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import net.posprinter.posprinterface.IMyBinder;
import net.posprinter.posprinterface.ProcessData;
import net.posprinter.posprinterface.TaskCallback;
import net.posprinter.service.PosprinterService;
import net.posprinter.utils.BitmapProcess;
import net.posprinter.utils.BitmapToByteData;
import net.posprinter.utils.DataForSendToPrinterPos80;
import net.posprinter.utils.DataForSendToPrinterPos76;
import net.posprinter.utils.PosPrinterDev;
import net.posprinter.utils.StringUtils;

import static net.posprinter.utils.StringUtils.byteMerger;
import static net.posprinter.utils.StringUtils.strTobytes;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

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
    private static final String ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION";

    Context context;

    public SavanitdevThermalPrinterModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

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
            Toast toast = Toast.makeText(context, "disconnect", Toast.LENGTH_SHORT);
            toast.show();
        }
    };

    @ReactMethod
    public void checkStatusBLE(Promise promise) {
        if (ISCONNECT == true) {
            promise.resolve("connect");
        } else {
            promise.reject("disconnect");
            ISCONNECT = false;
        }
    }

    @ReactMethod
    private void printBitmapBLE2(String base64String, int w1, int w2, int isBLE, Promise promise) {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
            promise.reject("turnoff");

        } else {
            final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), w1);

            if (ISCONNECT) {
                myBinder.WriteSendData(new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        promise.resolve("1");
                    }

                    @Override
                    public void OnFailed() {
                        promise.reject("", "OnFailed print img");
                        disConnectNet();
                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {
                        List<byte[]> list = new ArrayList<>();
                        list.add(DataForSendToPrinterPos76.initializePrinter());
                        list.add(DataForSendToPrinterPos76.selectBmpModel(0, bitmap1,
                                BitmapToByteData.BmpType.Dithering));
                        list.add(DataForSendToPrinterPos76.printAndFeedLine());
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
                    StringUtils.byteMerger(new byte[] { 31, 27, 31, -1 }, new byte[] { (byte) codepageByte, 10, 0 }));
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
                        promise.resolve("1");
                    }

                    @Override
                    public void OnFailed() {
                        promise.reject("", "OnFailed print img");
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
                context.registerReceiver(BtReciever, filterStart);
                context.registerReceiver(BtReciever, filterEnd);
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
        // registerReceiver(mUsbPermissionActionReceiver, filter);
        context.registerReceiver(mUsbPermissionActionReceiver, filter);

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

    @ReactMethod
    public void onCreate() {
        Intent intent = new Intent(context, PosprinterService.class);
        context.bindService(intent, mSerconnection, BIND_AUTO_CREATE);
        tryGetUsbPermission();
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
    private void connectNetImg(String ip, String base64String, int w1, int w2, Promise promise) {

        if (ip != null) {
            if (ISCONNECT) {
                myBinder.DisconnectCurrentPort(new TaskCallback() {
                    @Override
                    public void OnSucceed() {

                    }

                    @Override
                    public void OnFailed() {

                    }
                });
            } else {
                myBinder.ConnectNetPort(ip, 9100, new TaskCallback() {
                    @Override
                    public void OnSucceed() {
                        ISCONNECT = true;

                        printBitmap(base64String, w1, w2, promise);
                    }

                    @Override
                    public void OnFailed() {
                        ISCONNECT = false;

                        disConnectNet();
                    }
                });
            }

        } else {

        }

    }

    @ReactMethod
    private void printBitmap(String base64String, int w1, int w2, Promise promise) {
        final Bitmap bitmap1 = BitmapProcess.compressBmpByYourWidth(decodeBase64ToBitmap(base64String), w1);

        if (ISCONNECT) {
            myBinder.WriteSendData(new TaskCallback() {
                @Override
                public void OnSucceed() {
                    promise.resolve("1");

                }

                @Override
                public void OnFailed() {
                    promise.reject("", "OnFailed print img");
                    disConnectNet();

                }
            }, new ProcessData() {
                @Override
                public List<byte[]> processDataBeforeSend() {
                    List<byte[]> list = new ArrayList<>();
                    list.add(DataForSendToPrinterPos80.initializePrinter());
                    list.add(DataForSendToPrinterPos80.printRasterBmp(0, bitmap1, BitmapToByteData.BmpType.Dithering,
                            BitmapToByteData.AlignType.Right, w2));
                    list.add(DataForSendToPrinterPos80.printAndFeedLine());
                    list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(0x42, 0x66));
                    return list;
                }
            });
        } else {
            promise.reject("", "OnFailed print img");
            disConnectNet();

        }
    }

    @ReactMethod
    private void pingPinter(String ip, Promise promise) {

        if (ip != null) {
            myBinder.ConnectNetPort(ip, 9100, new TaskCallback() {
                @Override
                public void OnSucceed() {
                    // disConnectNet();
                    promise.resolve(ip);
                    Log.e("App Notify connectNet", "connect OnSucceed");
                }

                @Override
                public void OnFailed() {
                    // disConnectNet();
                    promise.reject("", "OnFailed connect der");
                    Log.e("App Notify connectNet", "connect OnFailed");

                }
            });

        } else {
            promise.reject("", "OnFailed connect der 2 ");
            Log.e("App Notify connectNet", "connect OnFailed");
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
                    promise.reject("0", "OnFailed printImg");
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
                        promise.reject(Boolean.toString(ISCONNECT));
                    }
                });
            } else {
                myBinder.ConnectNetPort(ip, 9100, new TaskCallback() {
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
            }

        } else {

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
        setPrinter.add(StringUtils.strTobytes(text, charset));
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
        String line = new String(new char[length]).replace("\0", ".");

        // Convert the string to bytes using the existing method
        byte[] lineBytes = strTobytes(line);

        // Add a carriage return and line feed to move to the next line
        byte[] newline = new byte[] { 13, 10 }; // CR LF

        // Combine the line bytes with the newline bytes
        byte[] data = byteMerger(lineBytes, newline);

        setPrinter.add(data);
    }

    @ReactMethod
    public void line2(int length) {
        String line = new String(new char[length]).replace("\0", "-");

        // Convert the string to bytes using the existing method
        byte[] lineBytes = strTobytes(line);

        // Add a carriage return and line feed to move to the next line
        byte[] newline = new byte[] { 13, 10 }; // CR LF

        // Combine the line bytes with the newline bytes
        byte[] data = byteMerger(lineBytes, newline);

        setPrinter.add(data);
    }

    @ReactMethod
    public void line3(int length) {
        String line = new String(new char[length]).replace("\0", "=");

        // Convert the string to bytes using the existing method
        byte[] lineBytes = strTobytes(line);

        // Add a carriage return and line feed to move to the next line
        byte[] newline = new byte[] { 13, 10 }; // CR LF

        // Combine the line bytes with the newline bytes
        byte[] data = byteMerger(lineBytes, newline);

        setPrinter.add(data);
    }

}
