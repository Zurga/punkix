/*
This file was generated by the Surface compiler.
*/

function ns(hooks, nameSpace) {
  const updatedHooks = {}
  Object.keys(hooks).map(function(key) {
    updatedHooks[`${nameSpace}#${key}`] = hooks[key]
  })
  return updatedHooks
}

import * as c1 from "./Punkix.Web.Components.InteractionRecorder.hooks"

let hooks = Object.assign(
  ns(c1, "Punkix.Web.Components.InteractionRecorder")
)

export default hooks