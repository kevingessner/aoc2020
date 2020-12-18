import scala.util.parsing.combinator._;

object Expr extends RegexParsers {
  def number: Parser[Long] = """\d+""".r ^^ { _.toLong }
  def parens: Parser[Long] = "(" ~> p <~ ")"
  def term: Parser[Long] = number | parens
  def op: Parser[String] = "+" | "*"

  def process(op: String) = (x: Long, y: Long) => op match {
    case "+" => x + y
    case "*" => x * y
  }

  def p: Parser[Long] = chainl1(term, op ^^ process)

  def eval(expr: String): Long = {
    parseAll(p, expr) match {
      case Success(result, _) => result
      case failure : NoSuccess => scala.sys.error(failure.msg)
    }
  }
}

object Main {

  def main(args: Array[String]) = {
    System.out.println(Expr.eval("4 + 2 * 3")); // 18
    System.out.println(Expr.eval("4 + (2 * 3)")); // 10
    System.out.println(Expr.eval("(4 + 2) * 3")); // 18
    System.out.println(Expr.eval("1 + 2 * 3 + 4 * 5 + 6")); // 71
    System.out.println(Expr.eval("1 + (2 * 3) + (4 * (5 + 6))")); // 51
    System.out.println(Expr.eval("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")); // 13632

    var total: Long = 0
    for (line <- scala.io.Source.fromFile("../prob.in").getLines) {
      val n = Expr.eval(line)
      System.out.println(s"handling $line = $n")
      total += n
    }
    System.out.println(s"total: $total")
  }
}
