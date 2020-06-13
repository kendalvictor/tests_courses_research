case class Ventana(val ancho:Int,val alto:Int)

object ejemplo{
  
  def main(arg: Array[String]): Unit = {
    val ventana= Ventana(300, 410)
    Console.println("ancho: "+ventana.ancho)
    Console.println("alto: "+ventana.alto)
  }
}

