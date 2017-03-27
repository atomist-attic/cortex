package com.atomist.rug.ts

import java.io.PrintWriter

import com.atomist.rug.ts.DefaultTypeGeneratorConfig.getClass
import com.atomist.util.Utils
import org.apache.commons.io.IOUtils

object DefaultTypeGeneratorConfig {

  val DefaultCortexJsonLocation = "/com/atomist/rug/ts/cortex.json"

  lazy val CortexJson: String =
    IOUtils.toString(getClass.getResourceAsStream(DefaultCortexJsonLocation), "UTF-8")
}

/**
  * Intended to run as part of build
  */
object CortexTypeGeneratorApp extends App {

  import CortexTypeGenerator._
  import DefaultTypeGeneratorConfig._

  // TODO could take second argument as URL of endpoint

  val arglist = args.toList

  val target = args.head
  val tsig = new CortexTypeGenerator(DefaultCortexDir, DefaultCortexStubDir)

  var output = tsig.toNodeModule(CortexJson)

  if (args.length > 1) {
    val sourceFile = arglist.tail.head

    output = tsig.toNodeModule(IOUtils.toString(getClass.getResourceAsStream(sourceFile), "UTF-8"))

  }

  println(s"Generated Type module")
  output.allFiles.foreach(f => Utils.withCloseable(new PrintWriter(target + "/" + f.path))(_.write(f.content)))
}
