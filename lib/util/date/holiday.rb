# encoding: utf-8
class Util::Date::Holiday
  def self.holiday?(year, month, day, wday = nil)
    wday ||= Date.new(year, month, day).strftime('%w').to_i

    # Jan.
    if month == 1
      return '元旦' if day == 1
      return '振替休日' if day == 2 && wday == 1
      return '成人の日' if 7 * 1 < day && day <= 7 * 2 && year >= 2000 && wday == 1
      # 廃止
      return '成人の日' if day == 15 && year < 2000

    # Feb.
    elsif month == 2
      return '建国記念日' if day == 11
      return '振替休日' if day == 12 && wday == 1
      return '天皇誕生日' if day == 23 && 2020 <= year
      return '振替休日' if day == 24 && wday == 1 && 2020 <= year

    # Mar.
    elsif month == 3
      haru = -1
      if 2100 <= year && year < 2150
        haru = 21.8510 + 0.242194 * (year - 1980)
        haru -= (haru - ((year - 1980) / 4).to_i).to_i.abs
      elsif 1980 <= year && year < 2100
        haru = 20.8431 + 0.242194 * (year - 1980)
        haru = (haru - ((year - 1980) / 4).to_i.abs).to_i.abs
      end

      return '春分の日' if day == haru
      return '振替休日' if day == 1 + haru && wday == 1

    # Apr.
    elsif month == 4
      if day == 29
        return '昭和の日' if year >= 2007
        return 'みどりの日' if year >= 1989
        return '天皇誕生日'
      end

      return '振替休日' if day == 30 && wday == 1

    # May
    elsif month == 5
      return '憲法記念日' if day == 3
      return 'みどりの日' if day == 4
      return 'こどもの日' if day == 5
      return '振替休日' if day == 6 && year >= 2007 && (wday == 2 || wday == 3)

    # June
    elsif month == 6

    # July
    elsif month == 7
      if year == 2020
        return '海の日' if day == 23
        return 'スポーツの日' if day == 24
      elsif year == 2021
        return '海の日' if day == 22
        return 'スポーツの日' if day == 23
      else
        return '海の日' if 7 * 2 < day && day <= 7 * 3 && year >= 2003 && wday == 1
        return '海の日' if day == 20 && 1996 <= year && year < 2003
      end
    # Aug.
    elsif month == 8
      return '山の日' if day == 10 && year == 2020
      return '山の日' if day == 8  && year == 2021
      return '山の日' if day == 11 && year >= 2016 && year != 2020 && year != 2021

    # Sep.
    elsif month == 9
      aki = 0
      if 1980 <= year && year < 2100
        aki = 23.2488 + 0.242194 * (year - 1980)
        aki = (aki - ((year - 1980) / 4).to_i.abs).to_i.abs
      elsif 2100 <= year && year < 2150
        aki = 24.2488 + 0.242194 * (year - 1980)
        aki = (aki - ((year - 1980) / 4).to_i.abs).to_i.abs
      end

      return '秋分の日' if day == aki
      return '振替休日' if day == 1 + aki && wday == 1
      return '敬老の日' if 7 * 2 < day && day <= 7 * 3 && year >= 2003 && wday == 1
      return '敬老の日' if day == 15 && 1966 <= year && year < 2003

    # Oct.
    elsif month == 10
      return '体育の日' if 7 * 1 < day && day <= 7 * 2 && year >= 2000 && wday == 1 && year <= 2019
      return 'スポーツの日' if 7 * 1 < day && day <= 7 * 2 && year >= 2022 && wday == 1
      return '体育の日' if day == 10 && 1996 <= year && year < 2000

    # Nov.
    elsif month == 11
      return '文化の日' if day == 3
      return '振替休日' if day == 4 && wday == 1
      return '勤労感謝の日' if day == 23
      return '振替休日' if day == 24 && wday == 1

    # Dec.
    elsif month == 12
      return '天皇誕生日' if day == 23 && 1989 <= year && 2018 >= year
      return '振替休日' if day == 24 && 1989 <= year && wday == 1 && 2018 >= year

    end

    false
  end
end
