''' convert this to dart and use it to fetch the prices of the coins, also convert it to python '''

import { ExchangeFiatValueRepo } from '../repos/ExchangeFiatValueRepo'

export class ExchangeFiatValueService {
  private static validTickers = ['EVR', 'RVN', 'SATORI'] // Add more tickers as needed

  static async getFiatValue(ticker: string, amount: number): Promise<string> {
    // Return '0' if the ticker is not valid
    if (!this.validTickers.includes(ticker.toUpperCase())) {
      return '0'
    }

    try {
      const price = await ExchangeFiatValueRepo.getFiatValue(ticker)
      const fiatValue = price * amount
      return fiatValue.toFixed(2)
    } catch (error) {
      console.error('Error getting fiat value:', error)
      return '0'
    }
  }
}


import axios from 'axios'

interface XeggexResponse {
  lastPrice: string
}

interface BinanceResponse {
  price: string
}

interface SafeTradeResponse {
  last: string
}

export class ExchangeFiatValueRepo {
  private static readonly XEGGEX_BASE_URL = 'https://api.xeggex.com/api/v2/market/getbysymbol/'
  private static readonly BINANCE_BASE_URL = 'https://api.binance.us/api/v3/ticker/price'
  private static readonly SAFETRADE_BASE_URL =
    'https://safe.trade/api/v2/trade/public/tickers/satoriusdt'

  static async getFiatValue(ticker: string): Promise<number> {
    try {
      let lastPrice: number

      if (ticker.toLowerCase() === 'evr') {
        lastPrice = await this.getXeggexPrice(ticker)
      } else if (ticker.toLowerCase() === 'rvn') {
        lastPrice = await this.getBinancePrice(ticker)
      } else if (ticker.toLowerCase() === 'satori') {
        lastPrice = await this.getSafeTradePrice(ticker)
      } else {
        throw new Error(`Unsupported ticker: ${ticker}`)
      }

      console.log(`ExchangeFiatValueRepo ${ticker} lastPrice:`, lastPrice)
      return lastPrice
    } catch (error) {
      console.error('Error fetching fiat value:', error)
      return 0
    }
  }

  private static async getXeggexPrice(ticker: string): Promise<number> {
    const response = await axios.get<XeggexResponse>(`${this.XEGGEX_BASE_URL}${ticker}/USDT`, {
      headers: {
        Accept: 'application/json'
      }
    })
    return this.parsePrice(response.data.lastPrice)
  }

  private static async getBinancePrice(ticker: string): Promise<number> {
    const response = await axios.get<BinanceResponse>(`${this.BINANCE_BASE_URL}`, {
      params: {
        symbol: `${ticker.toUpperCase()}USDT`
      }
    })
    return this.parsePrice(response.data.price)
  }

  private static async getSafeTradePrice(ticker: string): Promise<number> {
    const response = await axios.get<SafeTradeResponse>(`${this.SAFETRADE_BASE_URL}`, {
      params: {
        symbol: `${ticker.toUpperCase()}USDT`
      }
    })
    return this.parsePrice(response.data.last)
  }

  private static parsePrice(price: string): number {
    const parsedPrice = parseFloat(price)
    return isNaN(parsedPrice) ? 0 : parsedPrice
  }
}
