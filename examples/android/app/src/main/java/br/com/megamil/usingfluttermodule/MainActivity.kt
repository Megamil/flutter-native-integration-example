package br.com.megamil.usingfluttermodule

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import br.com.megamil.usingfluttermodule.databinding.ActivityMainBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import org.json.JSONObject

private const val FLUTTER_ENGINE_ID = "flutter_engine"
private const val CHANNEL = "br.com.megamil/callSDK"

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private var flutterEngine: FlutterEngine? = null

    override fun onResume() {
        super.onResume()
        //Garante que quando voltar de uma tela Flutter ele não irá ficar preso sempre nela
        FlutterEngineCache.getInstance().clear()
        flutterEngine = FlutterEngine(this)
        flutterEngine!!.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache
            .getInstance()
            .put(FLUTTER_ENGINE_ID, flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnWithParams.setOnClickListener {
            lifecycleScope.launch {
                callUserCreateScreen()
            }
        }

        binding.btnWithoutParams.setOnClickListener {
            lifecycleScope.launch {
                callSampleScreen()
            }
        }
    }

    private fun callSampleScreen() {
        val methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.invokeMethod("sample", null)

        startActivity(
            FlutterActivity
                .withCachedEngine(FLUTTER_ENGINE_ID)
                .build(this)
        )
    }

    @SuppressLint("SetTextI18n")
    private fun callUserCreateScreen() {
        val json = JSONObject()
        val randomGender = if ((0..1).random() == 0) "male" else "female"
        json.put("gender", randomGender)

        val methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.invokeMethod("newUser", json.toString())

// Outro exemplo, mas como lambda
//            methodChannel.invokeMethod("userCreated", null, object : MethodChannel.Result {
//                override fun success(result: Any?) {
//                    Log.d("TAG", "String retornada: $result")
//                }
//
//                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
//                    Log.e("TAG", errorMessage.toString())
//                }
//                override fun notImplemented() {
//                    Log.e("TAG", "Método não implementado")
//                }
//            })

        methodChannel.setMethodCallHandler {
                call, result ->
            if(call.method == "userCreated") {
                Log.i("tag", "returnByFlutter called \n ${call.arguments}")

                val rawJson = JSONObject(call.arguments.toString())
                val results = rawJson.getJSONArray("results")

                for (i in 0 until results.length()) {
                    val user = results.getJSONObject(i)
                    val rawName = user.optJSONObject("name") ?: JSONObject()
                    val name = "${rawName.optString("first", "")} ${rawName.optString("last", "")}"
                    val email = user.optString("email", "")
                    val phone = user.optString("phone", "")

                    val rawCity = user.optJSONObject("location") ?: JSONObject()
                    val city = rawCity.optString("city", "")

                    val picture = user.optJSONObject("picture") ?: JSONObject()
                    val urlImage = picture.optString("large", "")

                    binding.returnFlutter.text = "Valor retornado pelo Flutter:\n* Nome: $name,\n* E-mail: $email,\n* Telefone: $phone,\n* Cidade: $city,\n* Imagem: $urlImage"
                }

            }  else {
                result.notImplemented()
            }
        }

        startActivity(
            FlutterActivity
                .withCachedEngine(FLUTTER_ENGINE_ID)
                .build(this)
        )
    }

}