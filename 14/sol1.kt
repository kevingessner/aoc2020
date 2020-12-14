// `kotlinc sol1.kt -include-runtime -d sol.jar && kotlin sol.jar <input`

fun maskOnBits(mask: String): Long {
    return mask.replace("X", "0").toLong(2)
}

fun maskOffBits(mask: String): Long {
    return mask.replace("X", "1").toLong(2)
}

fun masked(mask: String, value: Long): Long {
    // apply mask: turn on the 1 bits (with or, and the Xs as 0s to be a noop) and turn off the 0 bits (with and, and
    // the Xs as 1s to be a noop)
    val maskOn = maskOnBits(mask)
    val maskOff = maskOffBits(mask)
    return ((value and maskOff) or maskOn)
}

class Mem {
    val memory = MutableList(100000, { _ -> 0L })
    var mask = ""

    fun setValue(pos: Int, value: Long) {
        println("setting $pos to $value ($mask)")
        memory.set(pos, masked(mask, value))
    }

}

fun main() {
    println(masked("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X", 11))
    println(masked("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X", 101))
    println(masked("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X", 0))

    var mem = Mem()
    var line = readLine()
    do {
        when (line!!.substring(0, 3)) {
            "mas" -> mem.mask = line.substring(7)
            "mem" -> {
                val splits = line.split('[', ']', ' ')
                mem.setValue(splits[1].toInt(), splits[4].toLong())
            }
            else -> print("dunno what to do with $line")
        }
        line = readLine()
    } while(line != null)
    println("done " + mem.memory.sum())
}
