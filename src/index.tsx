import {
  Alert,
  NativeModules,
  PermissionsAndroid,
  Platform,
} from "react-native";

import { Buffer } from "buffer";

const LINKING_ERROR =
  `The package 'react-native-savanitdev-thermal-printer' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: "" }) +
  "- You rebuilt the app after installing the package\n" +
  "- You are not using Expo Go\n";

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

export const PRINTER_TYPE = {
  NET: "IP",
  BLUETOOTH: "BLUETOOTH",
};

export const PRINT_MODE = {
  THERMAL: "THERMAL",
  LABEL: "LABEL",
};

export function connectNet(ip: string): Promise<boolean> {
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
export function connectUSB(usbAddress: string): Promise<boolean> {
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
export function GetPrinterStatus(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.GetPrinterStatus();
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
export function connectMulti(ip: string, portType: number): Promise<string> {
  // type = 0=NET,1=BT,2=USB
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.connectMulti(ip, portType);
  } else {
    // IP must required for IOS
  }
}

export function printImgMulti(
  ip: string,
  base64String: string,
  width: number
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printRawDataMulti(ip, base64String, width);
  } else {
    // IP must required for IOS
  }
}
export function printRawDataMulti(
  printerName: string,
  base64String: string
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printRawDataMulti(
      printerName,
      base64String
    );
  } else {
    // IP must required for IOS
  }
}

export function clearLoops(ip: string): Promise<boolean> {
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

export function pingDevice(address: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.pingDevice(address);
  } else {
    // return SavanitdevThermalPrinter.readBuffer(address);
  }
}
export function disconnectAll(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.disconnectAll();
  } else {
    // return SavanitdevThermalPrinter.readBuffer(address);
  }
}

export function isConnectMulti(address: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.isConnectMulti(address);
  } else {
    // return SavanitdevThermalPrinter.readBuffer(address);
  }
}

export function clearBufferMulti(address: string, type: string) {
  if (Platform.OS === "ios") {
    if (type === PRINTER_TYPE.NET) {
      SavanitdevThermalPrinter.clearBufferMulti(address);
    }
    if (type === PRINTER_TYPE.BLUETOOTH) {
      // SavanitdevThermalPrinter.clearBufferBLE();
    }
  }
  if (Platform.OS === "android") {
    SavanitdevThermalPrinter.clearBufferMulti(address);
  }
}

export function disconnectMulti(address: string, type: string) {
  if (Platform.OS === "ios") {
    if (type === PRINTER_TYPE.NET) {
      SavanitdevThermalPrinter.disconnectPort(address);
    }
    // if (type === PRINTER_TYPE.BLUETOOTH) {
    //   SavanitdevThermalPrinter.disconnectBLE(address);
    // }
  }

  if (Platform.OS === "android") {
    SavanitdevThermalPrinter.disconnectPort(address);
  }
}

export function printPicMulti(
  address: string,
  imagePath: string,
  opts: { size: number; width: number; mode: string; is_disconnect: boolean },
  type: string
) {
  if (type === PRINTER_TYPE.BLUETOOTH && Platform.OS === "ios") {
    return SavanitdevThermalPrinter.printPicBLE(address, imagePath, opts);
  }

  SavanitdevThermalPrinter.printPicMulti(address, imagePath, opts);
}

export function printImgWithTimeout(
  base64String: string,
  size: number,
  isCutPaper: boolean,
  cutCount: number,
  width: number,
  timeout: number
) {
  SavanitdevThermalPrinter.printImgWithTimeout(
    base64String,
    size,
    isCutPaper,
    cutCount,
    width,
    timeout
  );
}
export async function getPrinterInfoList(): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.getPrinterInfoList();
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function GetPrinterStatusMulti(
  printerName: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.GetPrinterStatus(printerName);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function removeMulti(printerName: string): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.removeMulti(printerName);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
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

// Xprinter

export async function printRawDataX(
  index: number,
  encode: string
): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.printRawDataX(index, encode);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
export async function connectNetX(ip: string, index: number): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.connectNetX(ip, index);
  } else {
    // IP just required for IOS
    // return await SavanitdevThermalPrinter.getPrinterInfoList();
  }
}
