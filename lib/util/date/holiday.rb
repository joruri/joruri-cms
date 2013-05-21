# encoding: utf-8
class Util::Date::Holiday
  def self.holiday?(year, month, day, wday = nil)
    wday ||= Date.new(year, month, day).strftime("%w").to_i
    
    # Jan.
    if month == 1
      if day == 1
        return '元旦'
      elsif day == 2 && wday == 1
        return '振替休日'
      elsif 7 * 1 < day && day <= 7 * 2 && year >= 2000 && wday == 1
        return '成人の日'
      elsif day == 15 && year < 2000
        return '成人の日'# 廃止
      end
      
    # Feb.
    elsif month == 2
      if day == 11
        return '建国記念日'
      elsif day == 12 && wday == 1
        return '振替休日'
      end
      
    # Mar.
    elsif month == 3
      haru = -1
      if 2100 <= year && year < 2150
        haru = ( 21.8510+0.242194*(year-1980) - ((year-1980)/4).to_i ).to_i.abs
      elsif 1980 <= year && year < 2100
        haru = ( 20.8431+0.242194*(year-1980) - ((year-1980)/4).to_i.abs ).to_i.abs
      end
      
      if day == haru
        return '春分の日'
      elsif day == 1 + haru && wday == 1
        return '振替休日'
      end
      
    # Apr.
    elsif month == 4
      if day == 29
        if year >= 2007
          return '昭和の日'
        elsif year >= 1989
          return 'みどりの日'
        else
          return '天皇誕生日'
        end
      elsif day == 30 && wday == 1
        return '振替休日'
      end
      
    # May
    elsif month == 5
      if day == 3
        return '憲法記念日'
      elsif day == 4
        return 'みどりの日'
      elsif day == 5
        return 'こどもの日'
      elsif day == 6 && year >= 2007 && (wday == 2 || wday == 3)
        return '振替休日'
      end
      
    # June
    elsif month == 6
      
    # July
    elsif month == 7
      if 7 * 2 < day && day <= 7 * 3 && year >= 2003 && wday == 1
        return '海の日'
      elsif day == 20 && 1996 <= year && year < 2003
        return '海の日'
      end
      
    # Aug.
    elsif month == 8
      
    # Sep.
    elsif month == 9
      aki = 0
      if 1980 <= year && year < 2100
        aki = ( 23.2488+0.242194*(year-1980) - ((year-1980)/4).to_i.abs ).to_i.abs
      elsif 2100 <= year && year < 2150
        aki = ( 24.2488+0.242194*(year-1980) - ((year-1980)/4).to_i.abs ).to_i.abs
      end
      
      if day == aki
        return '秋分の日'
      #elsif day + 1 == aki && 7 * 2 < day - 1 && day - 1 <= 7 * 3 && wday == 2)
      #  return '秋分の日'
      elsif day == 1 + aki && wday == 1
        return '振替休日'
      elsif 7 * 2 < day && day <= 7 * 3 && year >= 2003 && wday == 1
        return '敬老の日'
      elsif day == 15 && 1966 <= year && year < 2003
        return '敬老の日'
      end
      
    # Oct.
    elsif month == 10
      if 7 * 1 < day && day <= 7 * 2 && year >= 2000 && wday == 1
        return '体育の日'
      elsif day == 10 && 1996 <= year && year < 2000
        return '体育の日'
      end
      
    # Nov.
    elsif month == 11
      if day == 3
        return '文化の日'
      elsif day == 4 && wday == 1
        return '振替休日'
      elsif day == 23
        return '勤労感謝の日'
      elsif day == 24 && wday == 1
        return '振替休日'
      end
      
    # Dec.
    elsif month == 12
      if day == 23 && 1989 <= year
        return '天皇誕生日'
      elsif day == 24 && 1989 <= year && wday == 1
        return '振替休日'
      end
      
    end
    
    return false
  end
end