package com.savanitdevthermalprinter;

import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import java.util.ArrayList;

public class DeviceReceiver extends BroadcastReceiver {


    private ArrayList<String> deviceList_found = new ArrayList<String>();
    private ArrayAdapter<String> adapter;
    private ListView listView;

    public DeviceReceiver(ArrayList<String> deviceList_found, ArrayAdapter<String> adapter, ListView listView) {
        this.deviceList_found = deviceList_found;
        this.adapter = adapter;
        this.listView = listView;
    }

    @SuppressLint("MissingPermission")
    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (BluetoothDevice.ACTION_FOUND.equals(action)) {

            BluetoothDevice btd = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

            if (btd.getBondState() != BluetoothDevice.BOND_BONDED) {
                if (!deviceList_found.contains(btd.getName() + '\n' + btd.getAddress())) {
                    deviceList_found.add(btd.getName() + '\n' + btd.getAddress());
                    try {
                        adapter.notifyDataSetChanged();
                        listView.notify();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)){
        
            if(listView.getCount()==0){
                deviceList_found.add("");
                try{
                    adapter.notifyDataSetChanged();
                }catch (Exception e){
                    e.printStackTrace();
                }
            }


        }

    }
}
