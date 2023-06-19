import Glide from '@glidejs/glide'

const mountGlide = (ctxt) => {
  const element = ctxt
  const glides = document.querySelectorAll('.glide')
  for (let el of glides) {
    new Glide(el).mount()
  }
}
const glideHook = {
  mounted() {
    mountGlide(this)
  }
}

export { glideHook as default, glideHook }
