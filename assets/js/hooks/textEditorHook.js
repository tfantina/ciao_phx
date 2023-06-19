import MediumEditor from 'medium-editor'

const BUTTON_OPTIONS = [
  'bold',
  'italic',
  'anchor',
  'unorderedlist',
  'orderedlist',
  'h2',
  'h3',
  'quote'
]

const textEditorHook = {
  updated() {
    new MediumEditor(this.el, {
      toolbar: {
        buttons: BUTTON_OPTIONS
      },
    })
  },

  mounted() {
    new MediumEditor(this.el, {
      toolbar: {
        buttons: BUTTON_OPTIONS
      },
    })
  }
}

export { textEditorHook as default, textEditorHook }