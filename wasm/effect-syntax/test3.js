(function(a){typeof
globalThis!=="object"&&(this?b():(a.defineProperty(a.prototype,"_T_",{configurable:true,get:b}),_T_));function
b(){var
b=this||self;b.globalThis=b;delete
a.prototype._T_}}(Object));(()=>async a=>{"use strict";const
g=globalThis.process.emitWarning;globalThis.process.emitWarning=function(...a){if(a[1]!=="ExperimentalWarning")g(...a)};const{link:b,src:l}=a,{argv:f,env:h}=require("node:process"),{WASI:e}=require("node:wasi"),d=new
e({version:"preview1",args:f.slice(1),env:h,preopens:{".":".","/tmp":"/tmp"},returnOnExit:false}),c=d.getImportObject();function
k(a){const
b=require("node:path"),c=b.join(b.dirname(require.main.filename),a);return require("node:fs/promises").readFile(c)}async function
j(a){return WebAssembly.instantiate(await
a,c)}async function
i(){c.env={};c.OCaml={};const
d=[];async function
e(a,b){const
g=a[1].constructor!==Array;async function
f(){const
e=k(l+"/"+a[0]+".wasm");await
Promise.all(g?d:a[1].map(a=>d[a]));const
f=await
j(e);Object.assign(b?c.env:c.OCaml,f.instance.exports)}const
e=f();d.push(e);return e}async function
a(a){for(const
b
of
a)await
e(b)}await
e(b[0],1);if(b.length>1){await
e(b[1]);const
c=new
Array(20).fill(b.slice(2).values()).map(a);await
Promise.all(c)}return{instance:{exports:Object.assign(c.env,c.OCaml)}}}const
m=await
i();d.start(m.instance)})(function(a){"use strict";return{}}(globalThis))({"link":[["code",0]],"generated":{},"src":"test3.assets"});
