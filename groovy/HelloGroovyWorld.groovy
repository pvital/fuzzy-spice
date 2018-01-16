
class HelloGroovyWorld {

	static main(args) {
		def x = 42
		
		def helloworld = {
			println("Hello Grovvy World!!!!")
		}

		if ((x % 2) == 0) {
			helloworld()
		} else {
			println("Hello $x World!!!!!")
		}
	}

}
