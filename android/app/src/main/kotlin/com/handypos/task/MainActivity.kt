package com.handypos   //com.posapp

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()

/*
package com.handypos

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.os.Build
import java.util.UUID

class MainActivity : FlutterActivity() {

    private val CHANNEL = "flutter_thermal_printer_plus"
    private val TAG = "BluetoothFallback"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectViaFallback" -> {
                    val address = call.argument<String>("address")
                    if (address == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    // Run connection in background thread (Bluetooth operations must be off UI thread)
                    Thread {
                        val success = connectWithFallback(address)
                        runOnUiThread {
                            result.success(success)
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun connectWithFallback(macAddress: String): Boolean {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: return false
        if (!bluetoothAdapter.isEnabled) return false

        try {
            val device: BluetoothDevice = bluetoothAdapter.getRemoteDevice(macAddress)

            // List of UUIDs that work with 99% of cheap thermal printers
            val uuids = listOf(
                UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"), // Standard SPP
                UUID.fromString("00001101-0000-1000-8000-00805f9b34fb"), // lowercase
                UUID.fromString("8ce255c0-200a-11e0-ac64-0800200c9a66"), // Common fallback
            )

            for (uuid in uuids) {
                try {
                    val socket = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD_MR1) {
                        device.createInsecureRfcommSocketToServiceRecord(uuid)
                    } else {
                        device.createRfcommSocketToServiceRecord(uuid)
                    }

                    socket.connect()
                    socket.close()
                    return true // Success!
                } catch (e: Exception) {
                    // Ignore and try next UUID
                }
            }

            // Final desperate attempt — reflection method (works on many Chinese printers)
            try {
                val method = device.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType)
                val socket = method.invoke(device, 1) as android.bluetooth.BluetoothSocket
                socket.connect()
                socket.close()
                return true
            } catch (e: Exception) {
                e.printStackTrace()
            }

        } catch (ex: Exception) {
            ex.printStackTrace()
        }

        return false
    }
}
*/