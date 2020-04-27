const Main = require('../output/Main/index')

const store = Main.store()

store.subscribe(e => () => console.log("number is", e))()
store.dispatch(Main.Succ.value)()
store.dispatch(Main.Succ.value)()