package com.emall.chargingsocket;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import com.budiyev.android.codescanner.CodeScanner;
import com.budiyev.android.codescanner.CodeScannerView;
import com.budiyev.android.codescanner.DecodeCallback;
import com.google.zxing.Result;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URISyntaxException;

import io.socket.client.IO;
import io.socket.client.Socket;

public class MainActivity extends AppCompatActivity {
    private CodeScanner mCodeScanner;
    private Socket mSocket;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        CodeScannerView scannerView = findViewById(R.id.scanner_view);

        ImageView img = (ImageView) findViewById(R.id.imageView);
        img.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(MainActivity.this,SettingsActivity.class);
                startActivity(i);
            }
        });

        if(ContextCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[] {android.Manifest.permission.CAMERA}, 1888);
        }

        File file = new File(getApplicationContext().getFilesDir(),"config.json");
        if(!file.exists()){
            Toast.makeText(MainActivity.this, "Settings not found!", Toast.LENGTH_SHORT).show();
            writeToFile("[\"http://192.168.1.100:5000\",2,\"Tesla\",\"Via Giacomo Leopardi, 5, Cernusco sul naviglio\",\"2\"]", getApplicationContext());
        }

        String jsonString = readFromFile(getApplicationContext());
        JSONArray jarray = null;
        String station_id = "-1";
        String sock_num = "-1";
        try {
            jarray = new JSONArray(jsonString);
            station_id = jarray.get(1).toString();
            ((TextView)findViewById(R.id.NameText)).setText(jarray.get(2).toString());
            ((TextView)findViewById(R.id.AddressText)).setText(jarray.get(3).toString());
            sock_num = jarray.get(4).toString();
            ((TextView)findViewById(R.id.SockNumText)).setText(sock_num);
            try {
                Toast.makeText(MainActivity.this,"WebSocket: " + jarray.get(0).toString(), Toast.LENGTH_SHORT).show();
                mSocket = IO.socket(jarray.get(0).toString());
            } catch (URISyntaxException e) {}
        } catch (JSONException e) {
            Toast.makeText(MainActivity.this, e.toString(), Toast.LENGTH_SHORT).show();
        }

        mSocket.connect();

        final String CSID = station_id;
        final String SOID = sock_num;
        mCodeScanner = new CodeScanner(this, scannerView);
        mCodeScanner.setDecodeCallback(new DecodeCallback() {
            @Override
            public void onDecoded(@NonNull final Result result) {
                runOnUiThread(new Runnable() {
                    String decodedData = result.getText();
                    @Override
                    public void run() {
                        Toast.makeText(MainActivity.this, "Check your app to proceed!", Toast.LENGTH_SHORT).show();
                        JSONObject booking_data = new JSONObject();
                        try {
                            booking_data = new JSONObject("{\"station_id\":\"" + CSID + "\", \"sock_num\":\"" + SOID +"\", \"qrdata\": " + decodedData + "}");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        mSocket.emit("booking_check", booking_data);
                    }
                });
            }
        });
        scannerView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mCodeScanner.startPreview();
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        mCodeScanner.startPreview();
    }

    @Override
    protected void onPause() {
        mCodeScanner.releaseResources();
        super.onPause();
    }

    private void writeToFile(String data,Context context) {
        try {
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput("config.json", Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        }
        catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }

    private String readFromFile(Context context) {
        String ret = "";
        InputStream inputStream = null;

        try {
            inputStream = context.openFileInput("config.json");
            if ( inputStream != null ) {
                InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                String receiveString = "";
                StringBuilder stringBuilder = new StringBuilder();

                while ( (receiveString = bufferedReader.readLine()) != null ) {
                    stringBuilder.append(receiveString);
                }

                ret = stringBuilder.toString();
            }
        }
        catch (FileNotFoundException e) {
            Toast.makeText(MainActivity.this, "Can't find config file!", Toast.LENGTH_LONG).show();
            e.printStackTrace();
        } catch (IOException e) {
            Toast.makeText(MainActivity.this, "Error reading the file!", Toast.LENGTH_LONG).show();
            e.printStackTrace();
        }
        finally {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return ret;
    }
}