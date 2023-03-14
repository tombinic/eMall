package com.emall.chargingsocket;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

public class SettingsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        EditText name   = (EditText)findViewById(R.id.inputName);
        EditText addr   = (EditText)findViewById(R.id.inputAddress);
        EditText csid   = (EditText)findViewById(R.id.inputCSid);
        EditText soid   = (EditText)findViewById(R.id.inputSOid);
        EditText uri    = (EditText)findViewById(R.id.inputIP);

        String jsonString = readFromFile(getApplicationContext());
        JSONArray jarray = null;
        String station_id = "-1";
        String sock_num = "-1";
        try {
            jarray = new JSONArray(jsonString);
            station_id = jarray.get(1).toString();
            csid.setText(station_id);
            name.setText(jarray.get(2).toString());
            addr.setText(jarray.get(3).toString());
            sock_num = jarray.get(4).toString();
            soid.setText(sock_num);
            uri.setText(jarray.get(0).toString());
        } catch (JSONException e) {
            Toast.makeText(SettingsActivity.this, e.toString(), Toast.LENGTH_SHORT).show();
        }

        Button button = (Button) findViewById(R.id.btnConfSettings);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                EditText name   = (EditText)findViewById(R.id.inputName);
                EditText addr   = (EditText)findViewById(R.id.inputAddress);
                EditText csid   = (EditText)findViewById(R.id.inputCSid);
                EditText soid   = (EditText)findViewById(R.id.inputSOid);
                EditText uri    = (EditText)findViewById(R.id.inputIP);
                File file = new File(getApplicationContext().getFilesDir() + "config.json");
                file.delete();
                writeToFile("[\"" + uri.getText() + "\"," + csid.getText() +",\"" + name.getText() + "\",\"" + addr.getText() +"\",\"" + soid.getText() + "\"]", getApplicationContext());

                Intent i = new Intent(SettingsActivity.this,MainActivity.class);
                startActivity(i);
            }
        });
    }

    private void writeToFile(String data, Context context) {
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
            Toast.makeText(SettingsActivity.this, "Can't find config file!", Toast.LENGTH_LONG).show();
            e.printStackTrace();
        } catch (IOException e) {
            Toast.makeText(SettingsActivity.this, "Error reading the file!", Toast.LENGTH_LONG).show();
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