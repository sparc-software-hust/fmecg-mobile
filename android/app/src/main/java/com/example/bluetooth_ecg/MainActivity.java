package vn.sparc.fmecg;

import io.flutter.embedding.android.FlutterActivity;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;


import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


// import com.chaquo.python.PyObject;
// import com.chaquo.python.Python;
// import com.chaquo.python.android.AndroidPlatform;

import java.util.HashMap;
import java.util.Set;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.method_channel/java";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).
            setMethodCallHandler((call, result) -> {
                // if (call.method.equals("transfer_data_to_python")) {
                //     byte[] bytesData = call.argument("bytes");
                //     System.out.println("hello: " + bytesData);
                //     result.success(transferDataToPython(bytesData));
                // }

                // if (call.method.equals("transfer_context_to_python")) {
                //     String pythonPath = call.argument("python_path");
                //     String txtPath = call.argument("txt_path");
                //     if (pythonPath != null) {
                //         System.out.println("hello111: " + pythonPath);
                //         HashMap<String, int[]> dataCalculated = transferContextToPython(pythonPath, txtPath);
                //         result.success(dataCalculated);
                //     } else {
                //         System.out.println("helloeeeee: " + pythonPath);
                //         HashMap<String, int[]> dataCalculated = transferTxtPathAndCalculatePython(txtPath);
                //         result.success(dataCalculated);
                //     }
                // }
           });
    }


    // private HashMap<String, int[]> transferContextToPython(
    //     String pythonPath,
    //     String txtPath
    // ) {
    //     if (!Python.isStarted()) {
    //         Python.start(new AndroidPlatform(this));
    //     }

    //     Python py = Python.getInstance();
    //     PyObject module = py.getModule("bridge");
    //     PyObject data = module.callAttr("create_bridge", pythonPath, txtPath);

    //     // hoạt động với file backup ở máy chứ không phải file được chọn từ file picker
    //     // PyObject module = py.getModule("backup_script_bluetooth_classic");
    //     // PyObject data = module.callAttr("calculate", pcgPath, ppgPath);

    //     Set<PyObject> pyKeySet = data.callAttr("keys").asSet();
    //     HashMap<String, int[]> map = new HashMap<>();

    //     for (PyObject pyKey:pyKeySet) {
    //         String key = pyKey.toString();
    //         map.put(key, data.callAttr("get",key).toJava(int[].class));
    //     }
    //     return map;
    // }

    // private HashMap<String, int[]> transferTxtPathAndCalculatePython(
    //     String txtPath
    // ) {
    //     if (!Python.isStarted()) {
    //         Python.start(new AndroidPlatform(this));
    //     }

    //     Python py = Python.getInstance();
    //     // hoạt động với file backup ở máy chứ không phải file được chọn từ file picker
    //     PyObject module = py.getModule("main_script_bluetooth_classic");
    //     PyObject data = module.callAttr("calculate", txtPath);

    //     Set<PyObject> pyKeySet = data.callAttr("keys").asSet();
    //     HashMap<String, int[]> map = new HashMap<>();

    //     for (PyObject pyKey:pyKeySet) {
    //         String key = pyKey.toString();
    //         map.put(key, data.callAttr("get",key).toJava(int[].class));
    //     }
    //     return map;
    // }

    // private HashMap<String, String> transferDataToPython(
    //   byte[] bytesData
    // ) {
    //     if (!Python.isStarted()) {
    //         Python.start(new AndroidPlatform(this));
    //     }

    //     Python py = Python.getInstance();
    //     // get file python (PyObject)
    //     PyObject module = py.getModule("native");
    //     PyObject data = module.callAttr("helloWorld", bytesData);

    //     HashMap<String,String> map = new HashMap<>();
    //     //System.out.println(data.asMap().get("sbp").toString());

    //     Set<PyObject> pyKeySet = data.callAttr("keys").asSet();

    //     for ( PyObject pyKey:pyKeySet) {
    //         String key = pyKey.toString();
    //         map.put(key, data.callAttr("get",key).toString());
    //     }
    //     // map.put("sbp", data.asMap().get("sbp").toDouble());
    //     // map.put("dbp", data.asMap().get("dbp").toDouble());
    //     // map.put("heart_rate", data.asMap().get("heart_rate").toDouble());
    //     // map.put("standard_deviation", data.asMap().get("standard_deviation").toDouble());
    //     return map;
    // }
}
