// `kotlinc sol1.kt -include-runtime -d sol.jar && kotlin sol.jar <input`

fun maskOnBits(mask: String): Long {
    return mask.replace("X", "0").toLong(2)
}

fun maskOffBits(mask: String): Long {
    return mask.replace("X", "1").toLong(2)
}

// recursively masks `pos`, yielding all masked values: 0s are unchanged, 1s are forced on, Xs are both 0 and 1.
fun maskedPos(mask: String, pos: Long, after: Int = 0): Sequence<Long> {
    // apply the 1 bits
    var newpos = pos or maskOnBits(mask)
    //println("masking $pos $mask $newpos")
    return sequence {
        val nextX = mask.indexOf("X", after)
        if (nextX == -1) {
            // no more Xs -- just yield what we have after masking
            yield(newpos)
        } else {
            // replace the bit at leftmost X with 1 and 0 in the pos, and recur. replace the X with 0 so it doesn't have
            // any more effect in the mask -- we're applying the bit changing here.
            val bitmask = 1L.shl(35 - nextX)
            // forced on
            yieldAll(maskedPos(mask.replaceRange(nextX, nextX + 1, "0"), newpos or bitmask, nextX + 1))
            // forced off
            yieldAll(maskedPos(mask.replaceRange(nextX, nextX + 1, "0"), newpos and bitmask.inv(), nextX + 1))
        }
    }
}

class Mem {
    val memory = mutableMapOf<Long, Long>().withDefault({ _ -> 0L })
    var mask = ""

    fun setValue(pos: Long, value: Long) {
        println("setting $pos to $value ($mask)")
        for (newpos in maskedPos(mask, pos)) {
            memory[newpos] = value
        }
    }

}

fun main() {
    for (newpos in maskedPos("000000000000000000000000000000X1001X", 42)) {
        println(newpos)
    }
    for (newpos in maskedPos("00000000000000000000000000000000X0XX", 26)) {
        println(newpos)
    }
    var mem = Mem()
    var line = readLine()
    do {
        when (line!!.substring(0, 3)) {
            "mas" -> mem.mask = line.substring(7)
            "mem" -> {
                val splits = line.split('[', ']', ' ')
                mem.setValue(splits[1].toLong(), splits[4].toLong())
            }
            else -> print("dunno what to do with $line")
        }
        line = readLine()
    } while(line != null)
    println("done " + mem.memory.values.sum())
}
