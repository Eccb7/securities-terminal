import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="market-data"
export default class extends Controller {
  static targets = ["price", "change", "volume"]
  static values = {
    securityId: Number
  }

  connect() {
    this.channel = createConsumer().subscriptions.create(
      { channel: "MarketChannel" },
      {
        connected: this._connected.bind(this),
        disconnected: this._disconnected.bind(this),
        received: this._received.bind(this)
      }
    )
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }

  _connected() {
    console.log("Connected to MarketChannel")
  }

  _disconnected() {
    console.log("Disconnected from MarketChannel")
  }

  _received(data) {
    if (data.type === "quote_update") {
      this._updateQuote(data)
    }
  }

  _updateQuote(data) {
    // Only update if this is the right security
    if (this.securityIdValue && data.security_id !== this.securityIdValue) {
      return
    }

    const quote = data.quote

    // Update price
    if (this.hasPriceTarget) {
      this.priceTarget.textContent = this._formatCurrency(quote.last_price)
      this._flashElement(this.priceTarget)
    }

    // Update change
    if (this.hasChangeTarget && quote.price_change_pct) {
      const changeText = `${quote.price_change >= 0 ? '+' : ''}${this._formatNumber(quote.price_change)} (${quote.price_change_pct}%)`
      this.changeTarget.textContent = changeText
      
      // Update color based on direction
      this.changeTarget.classList.remove('text-green-600', 'text-red-600', 'text-gray-600')
      if (quote.price_change > 0) {
        this.changeTarget.classList.add('text-green-600')
      } else if (quote.price_change < 0) {
        this.changeTarget.classList.add('text-red-600')
      } else {
        this.changeTarget.classList.add('text-gray-600')
      }
      
      this._flashElement(this.changeTarget)
    }

    // Update volume
    if (this.hasVolumeTarget && quote.volume) {
      this.volumeTarget.textContent = this._formatNumber(quote.volume)
      this._flashElement(this.volumeTarget)
    }
  }

  _formatCurrency(value) {
    return new Intl.NumberFormat('en-KE', {
      style: 'currency',
      currency: 'KES',
      minimumFractionDigits: 2
    }).format(value)
  }

  _formatNumber(value) {
    return new Intl.NumberFormat('en-KE').format(value)
  }

  _flashElement(element) {
    element.classList.add('animate-pulse')
    setTimeout(() => {
      element.classList.remove('animate-pulse')
    }, 500)
  }
}
