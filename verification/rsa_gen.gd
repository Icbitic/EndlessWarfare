extends Node


func _ready():
	Console.add_command("sign", self, "_sign_cmd")\
	.set_description("Sign")\
	.register()
	
	Console.add_command("verify", self, "_verify_cmd")\
	.set_description("Verify")\
	.register()
	
	Console.add_command("genkey", self, "_gen_key_cmd")\
	.set_description("Generate Keys")\
	.register()
	return OK
	
func _verify(signature):
	var data = OS.get_unique_id()
	var crypto = Crypto.new()
	var key = CryptoKey.new()
	key.load("user://pub.pub", true)
	# Verifying
	var verified = crypto.verify(HashingContext.HASH_SHA256, data.sha256_buffer(), signature, key)
	
	return verified

func _sign():
	var data = OS.get_unique_id()
	var crypto = Crypto.new()
	var key = CryptoKey.new()
	key.load("user://pri&pub.key")
	# Signing
	var signature = crypto.sign(HashingContext.HASH_SHA256, data.sha256_buffer(), key)
	return signature

func _verify_cmd():
	var config = ConfigFile.new()
	#var err = config.load("user://settings.cfg")
	var err = config.load_encrypted_pass("signature.sig", "123456")
	
	if err != OK:
		Logger.error("Error occurred when trying to load signature.sig.")
		return err
	
	var signature = config.get_value("Tech", "sign")
	
	var result = _verify(signature)
	
	if result == true:
		Console.write_line("Verification result: True")
	else:
		Console.write_line("Verification result: False")
		
	return OK

func _sign_cmd():
	var signature = _sign()
	
	var config = ConfigFile.new()
	config.set_value("Tech", "sign", signature)
	config.save_encrypted_pass("signature.sig", "123456")
	Console.write_line("Signature saved")
	return OK

func _gen_key_cmd():
	var crypto = Crypto.new()
	var key = CryptoKey.new()
	# Generate new RSA key.
	key = crypto.generate_rsa(4096)
	# Generate new self-signed certificate with the given key.
	# Save key and certificate in the user folder.
	key.save("user://pri&pub.key")
	key.save("user://pub.pub", true)
