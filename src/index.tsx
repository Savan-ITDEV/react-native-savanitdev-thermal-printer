import {
  Alert,
  NativeModules,
  PermissionsAndroid,
  Platform,
} from "react-native";

import { Buffer } from "buffer";

const LINKING_ERROR =
  `please check your project to install correctly, if you need special support please contact me ^^` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: "" }) +
  "- You rebuilt the app after installing the package\n" +
  "- Fanpage : SavanITDev";

const SavanitdevThermalPrinter = NativeModules.SavanitdevThermalPrinter
  ? NativeModules.SavanitdevThermalPrinter
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const ZyWell = NativeModules.ZyWell
  ? NativeModules.ZyWell
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const XPrinter = NativeModules.Xprinter
  ? NativeModules.Xprinter
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

// init printer and request permissions
export function initializePrinter() {
  if (Platform.OS === "android") {
    handleAndroidPermissions();
  } else {
    return SavanitdevThermalPrinter.initializePrinter();
  }
}

// Android native call function

export function connectNet(ip: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.connectNet(ip);
  } else {
    return SavanitdevThermalPrinter.connectNet(ip);
  }
}

export function getUSB(): Promise<String> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.getUSB();
  } else {
    return SavanitdevThermalPrinter.getUSB();
  }
}
export function connectUSB(usbAddress: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.connectUSB(usbAddress);
  } else {
    return SavanitdevThermalPrinter.connectUSB(usbAddress);
  }
}

export async function printImgNet(
  ip: string,
  img: string,
  w1: number,
  w2: number,
  isDisconnect = true
): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.printImg(img, w1, w2, 0);
  } else {
    return SavanitdevThermalPrinter.printImgNet(ip, img, isDisconnect);
  }
}
export async function printImgNetSticker(
  ip: string,
  img: string,
  w1: number,
  w2: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.printImg(img, w1, w2, 1);
  } else {
    return SavanitdevThermalPrinter.printImgNetSticker(ip, img, false);
  }
}

export const handleAndroidPermissions = () => {
  try {
    if (Platform.OS === "android" && Platform.Version >= 31) {
      PermissionsAndroid.requestMultiple([
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
      ]).then((result: any) => {
        if (result) {
          // console.debug(
          //   "[handleAndroidPermissions] User accepts runtime permissions android 12+"
          // );
        } else {
          console.error(
            "[handleAndroidPermissions] User refuses runtime permissions android 12+"
          );
        }
      });
    } else if (Platform.OS === "android" && Platform.Version >= 23) {
      PermissionsAndroid.check(
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
      ).then((checkResult: any) => {
        if (checkResult) {
          // console.debug(
          //   "[handleAndroidPermissions] runtime permission Android <12 already OK"
          // );
        } else {
          PermissionsAndroid.request(
            PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
          ).then((requestResult: any) => {
            if (requestResult) {
              // console.debug(
              //   "[handleAndroidPermissions] User accepts runtime permission android <12"
              // );
            } else {
              console.error(
                "[handleAndroidPermissions] User refuses runtime permission android <12"
              );
            }
          });
        }
      });
    }
  } catch (error) {
    console.log("error ", error);
  }
};

export async function disConnect(ip: string): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.disConnectNet();
  } else {
    // IP just required for IOS
    return await SavanitdevThermalPrinter.disconnectNet(ip);
  }
}

export function findAvailableDevice() {
  if (Platform.OS === "android") {
    const arr = [];
    return SavanitdevThermalPrinter.findAvailableDevice().then(
      (bluetoothDevices: {
        [x: string]: any;
        hasOwnProperty: (arg0: string) => any;
      }) => {
        for (const deviceName in bluetoothDevices) {
          if (bluetoothDevices.hasOwnProperty(deviceName)) {
            const deviceAddress: string = bluetoothDevices[deviceName];
            const body = {
              name: deviceAddress.split(",")[0],
              deviceAddress: deviceAddress.split(",")[1],
            };
            arr.push(body);
          }
        }
        // console.log("Lists device found : ", arr);
        return arr;
      }
    );
  }
}
export function printText(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printText();
  }
}
export function StopMonitorPrinter(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.StopMonitorPrinter();
  }
}
export function printRawData(
  encode: string,
  ip: string,
  isDisconnect = true
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printRawData(encode);
  } else {
    // IP must required for IOS
    return SavanitdevThermalPrinter.printEncodeNet(ip, encode, isDisconnect);
  }
}

export function clearLoops(ip: string): Promise<string> {
  if (Platform.OS === "android") {
  } else {
    return SavanitdevThermalPrinter.clearLoops();
  }
}

// BLEUTOOTH //

export function connectBT(macAddress: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.connectBT(macAddress);
  } else {
    return SavanitdevThermalPrinter.connectBLE(macAddress);
  }
}
export function checkStatusBLE(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.checkStatusBLE();
  } else {
    return SavanitdevThermalPrinter.checkStatusBLE("");
  }
}
export function disconnectBLE(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.disConnectBT();
  } else {
    return SavanitdevThermalPrinter.disconnectBLE("");
  }
}

export function printLangPrinter(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printLangPrinter();
  } else {
    return SavanitdevThermalPrinter.printLangPrinter();
  }
}
export function setLang(codepage = "70"): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.setLang(codepage);
  } else {
    return SavanitdevThermalPrinter.setLang(codepage);
  }
}
export function getLangModel(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.getLangModel();
  } else {
    return SavanitdevThermalPrinter.getLangModel();
  }
}
export function cancelChinese(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.cancelChinese();
  } else {
    return SavanitdevThermalPrinter.cancelChinese();
  }
}
export function initialPrinter(): Promise<string> {
  if (Platform.OS === "android") {
    handleAndroidPermissions();
    return SavanitdevThermalPrinter.onCreate();
  } else {
    return SavanitdevThermalPrinter.initBLE();
  }
}

export function requestUSBPermission(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.tryGetUsbPermission();
  } else {
  }
}

export function getByteArrayList(): Promise<Object> {
  return SavanitdevThermalPrinter.getByteArrayList()
    .then((base64Strings: []) => {
      const byteArrayList = base64Strings.map(
        (base64) => Buffer.from(base64, "base64").toJSON().data
      );
      const combined = byteArrayList.flat();
      return combined;
    })
    .catch((error) => {
      console.error("error", error);
    });
}
export async function getListDevice(): Promise<any[]> {
  if (Platform.OS === "android") {
  } else {
    return await SavanitdevThermalPrinter.getListDevice("");
  }
}

export async function startScanBLE(): Promise<any[]> {
  if (Platform.OS === "android") {
    return findAvailableDevice();
  } else {
    try {
      const arr = [];
      SavanitdevThermalPrinter.startScanBLE();
      return new Promise<any[]>(async (resolve, reject) => {
        getListDevice()
          .then((data) => {
            const body = data.map((i, k) => ({
              name: `${i.name}-${k}`,
              deviceAddress: i.identifier,
            }));
            resolve(body);
          })
          .catch((err) => {
            reject([]);
          });
      });
    } catch (error) {
      return [];
    }
  }
}
export function printImgByte(base64String: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printImgByte(base64String);
  } else {
    // return SavanitdevThermalPrinter.printImgByte(base64String);
  }
}
export function ClearBuffer(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.ClearBuffer();
  } else {
  }
}
export function ReadBuffer(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.ReadBuffer();
  } else {
  }
}

export function rawDataBLE(base64String: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printRawData(base64String);
  } else {
    return SavanitdevThermalPrinter.rawDataBLE(base64String);
  }
}

export function image64BaseBLE(
  base64String: string,
  w1: number,
  w2: number,
  isCut: number
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printBitmapBLE(base64String, w1, w2, isCut);
  } else {
    return SavanitdevThermalPrinter.image64BaseBLE(base64String);
  }
}
// BLEUTOOTH //

export const printPOS = {
  printText: async function (): Promise<string> {
    return SavanitdevThermalPrinter.printText();
  },
  printTemplate: async function (
    ip: string,
    isDisconnect = true
  ): Promise<string> {
    if (Platform.OS === "ios") {
      return SavanitdevThermalPrinter.printTemplate(ip, isDisconnect);
    } else {
      printPOS.printText();
    }
  },
  initializeText: function () {
    return SavanitdevThermalPrinter.initializeText();
  },
  cut: function () {
    return SavanitdevThermalPrinter.cut();
  },
  clearPaper: function (): Promise<boolean> {
    return SavanitdevThermalPrinter.clearPaper();
  },
  printAndFeedLine: function () {
    return SavanitdevThermalPrinter.printAndFeedLine();
  },
  CancelChineseCharModel: function () {
    return SavanitdevThermalPrinter.CancelChineseCharModel();
  },
  selectAlignment: function selectAlignment(align: string) {
    let num = 1;
    if (align === "center") {
      num = 1;
    }
    if (align === "right") {
      num = 2;
    }
    if (align === "left") {
      num = 0;
    }
    return SavanitdevThermalPrinter.selectAlignment(num);
  },

  text: function (text: string, charset = "cp874") {
    return SavanitdevThermalPrinter.text(text, charset);
  },
  setImg: function (base64String: string, w1: number) {
    return SavanitdevThermalPrinter.setImg(base64String, w1);
  },
  selectCharacterSize: function (size: number) {
    return SavanitdevThermalPrinter.selectCharacterSize(size);
  },
  line: function (size: number) {
    return SavanitdevThermalPrinter.line(size);
  },
  line2: function (size: number) {
    return SavanitdevThermalPrinter.line2(size);
  },
  line3: function (size: number) {
    return SavanitdevThermalPrinter.line3(size);
  },
  selectOrCancelBoldModel: function (size: number) {
    return SavanitdevThermalPrinter.selectOrCancelBoldModel(size);
  },
  selectCharacterCodePage: function (hex: number) {
    return SavanitdevThermalPrinter.selectCharacterCodePage(hex);
  },
  selectInternationalCharacterSets: function (hex: number) {
    return SavanitdevThermalPrinter.selectInternationalCharacterSets(hex);
  },
  setAbsolutePrintPosition: function (n: number, m: number) {
    return SavanitdevThermalPrinter.setAbsolutePrintPosition(n, m);
  },
  setEncode: function (encode: string) {
    return SavanitdevThermalPrinter.setEncode(encode);
  },
};

export function pingDevice(address: string, timeout = 4000): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.pingDevice(address, timeout);
  } else {
    // return SavanitdevThermalPrinter.readBuffer(address);
  }
}

export const startPrinterDiscovery = async (timeout = 5000) => {
  try {
    const printers = await SavanitdevThermalPrinter.startQuickDiscovery(
      timeout
    );
    console.log("Discovered printers: ", printers);
    return printers;
  } catch (error) {
    console.error("Printer discovery failed: ", error);
    return [];
  }
};

// --------------- Lib ZyWell printer new function // ---------------

export function connectNetZyWell(ip: string): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.connectNetZyWell(ip);
  } else {
    // return ZyWell.connectNetZyWell(ip);
  }
}
export function connectBTZyWell(macAddress: string): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.connectBTZyWell(macAddress);
  } else {
    // return ZyWell.connectBTZyWell(ip);
  }
}
export function connectUSBZyWell(usbAddress: string): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.connectUSBZyWell(usbAddress);
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function disConnectZyWell(): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.disConnectZyWell();
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function disConnectNetZyWell(): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.disConnectNetZyWell();
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function printRawZyWell(encode: string): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.printRawZyWell(encode);
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function restartPrinter(): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.restartPrinter();
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function getPrinterStatus(): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.getPrinterStatus();
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function printImgZyWell(
  base64String: string,
  width: number,
  isCut: number
): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.printImgZyWell(base64String, width, isCut);
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function printImgWithTimeoutZyWell(
  base64String: string,
  page = 80,
  isCut: number,
  width: number,
  cutCount: number,
  timeout = 4000
): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.printImgWithTimeoutZyWell(
      base64String,
      page,
      width,
      isCut,
      width,
      cutCount,
      timeout
    );
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}

// ZyWell multiple connection
export async function getPrinterStatusMultiZyWell(
  printerName: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await ZyWell.getPrinterStatusZyWell(printerName);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function disconnectMultiZyWell(
  printerName: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.removeMulti(printerName);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}

export async function connectMultiZyWell(
  printerName: string,
  portType = "ETHERNET"
): Promise<string> {
  if (Platform.OS === "android") {
    const type = portType == "ETHERNET" ? 0 : portType == "BLUETOOTH" ? 1 : 2;
    return await ZyWell.connectMultiZyWell(printerName, type);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}

export async function isOnline(
  address: string,
  timeout = 2000
): Promise<string> {
  if (Platform.OS === "android") {
    return await ZyWell.isOnline(address, timeout);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function printImgMultiZyWell(
  printerName: string,
  base64String: string,
  width: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await ZyWell.printImgMultiZyWell(printerName, base64String, width);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function printRawDataMulti(
  printerName: string,
  base64String: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await ZyWell.printRawDataMulti(printerName, base64String);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function getPrinterInfoListMulti(): Promise<string> {
  if (Platform.OS === "android") {
    return await ZyWell.getPrinterInfoListMulti();
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export function printImgWithTimeoutMulti(
  printerName: string,
  base64String: string,
  page = 80,
  isCut = true,
  width: number,
  cutCount: number,
  timeout = 4000
): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.printImgWithTimeoutMulti(
      printerName,
      base64String,
      page,
      isCut,
      width,
      cutCount,
      timeout
    );
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}
export function printImgTSCZyWell(
  base64String: string,
  width: number,
  type: boolean,
  n: number,
  m: number,
  x: number,
  y: number,
  mode: number
): Promise<string> {
  if (Platform.OS === "android") {
    return ZyWell.printImgTSCZyWell(
      base64String,
      width,
      type,
      n,
      m,
      x,
      y,
      mode
    );
  } else {
    // return ZyWell.connectUSBZyWell(ip);
  }
}

// --------------- Lib XPrinter printer new function // ---------------

// Xprinter
export async function connectMultiXPrinter(
  address: string,
  portType: "ETHERNET"
): Promise<string> {
  const type = portType == "ETHERNET" ? 3 : portType == "BLUETOOTH" ? 2 : 1;
  if (Platform.OS === "android") {
    return await XPrinter.connectMultiXPrinter(address, type);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}

export function disConnectXPrinter(address: string) {
  return XPrinter.disConnectXPrinter(address);
}

export async function printImgESCX(
  address: string,
  base64String: string,
  width: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printImgESCX(address, base64String, width);
  } else {
    // IP just required for IOS
    return await SavanitdevThermalPrinter.printImgESC(
      address,
      base64String,
      width
    );
  }
}
export async function printRawDataESC(
  address: string,
  base64String: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printRawDataESC(address, base64String);
  } else {
    // IP just required for IOS
    return await SavanitdevThermalPrinter.printRawDataESC(
      address,
      base64String
    );
  }
}
export async function cutESCX(index: number): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.cutESCX(index);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}

//---------------  Xprinter Label --------------- ///

export async function printImgZPL(
  address: string,
  base64String: string,
  width: number,
  printCount: number,
  x: number,
  y: number
): Promise<string> {
  if (Platform.OS === "android") {
    return XPrinter.printImgZPL(address, base64String, width, printCount, x, y);
  } else {
    // IP just required for IOS
    return SavanitdevThermalPrinter.printImgZPL(
      address,
      base64String,
      width,
      printCount,
      x,
      y
    );
  }
}
export async function printImgTSPL(
  address: string,
  base64String: string,
  width: number,
  widthBmp: number,
  height: number,
  m: number,
  n: number,
  y: number,
  x: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printImgTSPL(
      address,
      base64String,
      width,
      widthBmp,
      height,
      m,
      n,
      y,
      x
    );
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function printImgCPCL(
  address: string,
  base64String: string,
  width: number,
  y: number,
  x: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printImgCPCL(address, base64String, width, y, x);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function printRawDataZPL(
  address: string,
  base64String: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printRawDataZPL(address, base64String);
  } else {
    // IP just required for IOS
    return await SavanitdevThermalPrinter.printRawDataZPL(
      address,
      base64String
    );
  }
}
export async function printRawDataCPCL(
  address: string,
  base64String: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printRawDataCPCL(address, base64String);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function printRawDataTSPL(
  address: string,
  base64String: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printRawDataTSPL(address, base64String);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function printerStatusZPL(
  address: string,
  timeout: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.printerStatus(address, timeout);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function setPrintDensityZPL(
  address: string,
  density: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.setPrintDensity(address, density);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function setPrintOrientationZPL(
  address: string,
  orientation: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.setPrintOrientation(address, orientation);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function setPrintSpeedZPL(
  address: string,
  speed: number
): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.setPrintSpeed(address, speed);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function statusXprinter(address: string): Promise<string> {
  if (Platform.OS === "android") {
    return await XPrinter.statusXprinter(address);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
