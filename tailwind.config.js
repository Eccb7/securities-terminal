module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        'terminal-bg': '#0a0e27',
        'terminal-blue': '#1e40af',
        'terminal-green': '#10b981',
        'terminal-red': '#ef4444',
      }
    },
  },
  plugins: [],
}
