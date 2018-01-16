import groovy.json.JsonSlurper 

// The Euro currency symbol to print: '\u20AC'

def Map getLatestCurrency(String currency = "EUR") {
	def url = "https://api.fixer.io/latest?base=${currency}"
	
	//println("Sending 'GET' request to URL : " + url);
	def connection = new URL(url).openConnection()
	
	// optional default is GET
	connection.setRequestMethod("GET")

	//add request header
	connection.setRequestProperty("User-Agent", "Mozilla/5.0")
	connection.setRequestProperty("Content-Type", "application/json")

	def responseCode = connection.getResponseCode();
	if (responseCode != 200) {
		println("**** ERROR while connecting ${url} \n Response Code: ${responseCode}");
		return []
	}	
	def jsonSlurper = new JsonSlurper()
	def object = jsonSlurper.parseText(connection.getInputStream().getText())
	return object
}

def doExchange2EUR(String currency) {
	//def currency = execution.getVariable("currency")
	def currencySupport = ["SEK", "USD", "DKK", "GBP", "BRL"]
	def currencyMap = getLatestCurrency()
	
	def value = 1.0000
	
	if (currencyMap['base'] == currency) {
		return 1.0000  * value
	} else if (currency in currencySupport) {
		return currencyMap['rates'][currency]  * value
	} else
		return 0.000
		
	//execution.setVariable("bpnEuro", euro)
}

println("What's the currency? ")
def reader = new BufferedReader(new InputStreamReader(System.in))
def userCurrency = reader.readLine()
def euro = doExchange2EUR(userCurrency)
println("1 \u20AC = ${euro} ${userCurrency} ")

/*
println("Testing http connection....")
todayCurrency = getLatestCurrency("BRL")
println(todayCurrency)
todayCurrency = getLatestCurrency()
println(todayCurrency)
*/
