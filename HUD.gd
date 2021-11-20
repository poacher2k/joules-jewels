extends CanvasLayer

func update_coins_text():
	var coins = Global.collected_coins.size()
	var coinPrefix = "0" if coins < 10 else ""
	$Coins.text = coinPrefix + String(coins) + ""


func _ready():
	$Letters.text = Global.collected_letters
	update_coins_text()

func on_Coin_collected(coin):
	Global.collect_coin(coin)

	update_coins_text()

	$Letters.text = Global.collected_letters

	if Global.collected_coins.size() == 1:
		get_tree().call_group("Portals", "coin_cap_reached")


