package com.atomist.rug.ts

import com.atomist.source.ArtifactSource
import org.scalatest.{FlatSpec, Matchers}

class CortexTypeGeneratorTest extends FlatSpec with Matchers {

  import CortexTypeGenerator._
  import DefaultTypeGeneratorConfig.CortexJson

  private val typeGen = new CortexTypeGenerator(DefaultCortexDir, DefaultCortexStubDir)

  "Type generation" should "find some types" in {
    val types = typeGen.extract(CortexJson)
    assert(types.nonEmpty)
  }

  it should "return types with operations" in {
    val types = typeGen.extract(CortexJson)
    types.foreach(t => {
      assert(t.operations.nonEmpty, s"Type ${t.name} should have operations")
    })
  }
}

object CortexTypeGeneratorTest {

  private val typeGen = new CortexTypeGenerator(CortexTypeGenerator.DefaultCortexDir, CortexTypeGenerator.DefaultCortexStubDir)

  val fullModel: ArtifactSource = {
    val as = typeGen.toNodeModule(DefaultTypeGeneratorConfig.CortexJson)
      .withPathAbove(".atomist/rug")
    TypeScriptBuilder.compiler.compile(as + TypeScriptBuilder.compileUserModel(Seq(
      TypeScriptBuilder.coreSource,
      as
    )))
  }
}
