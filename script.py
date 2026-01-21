import yt_dlp
import json
import os
import re
from datetime import datetime

# ==================== চ্যানেল কনফিগারেশন (ভবিষ্যতে এখানে যোগ/কমান) ====================
# এখানে id টি অবশ্যই আপনার data.json ফাইলের id এর সাথে মিলতে হবে।
CONFIG = {
    "nba": {
        "url": "https://www.youtube.com/@NBA/videos",
        "kw": ["Highlights"], 
        "m_keywords": ["Finals", "All-Star", "Playoffs"], # এগুলো পেলে m-এ বসাবে
        "limit": 300
    },
    "nfl": {
        "url": "https://www.youtube.com/@NFL/videos",
        "kw": ["Game Highlights"],
        "m_keywords": ["Super Bowl", "Postseason"],
        "limit": 200
    },
    "nhl": {
        "url": "https://www.youtube.com/@NHL/videos",
        "kw": ["Game Highlights"],
        "m_keywords": ["Stanley Cup"],
        "limit": 150
    },
    "mlb": {
        "url": "https://www.youtube.com/@MLB/videos",
        "kw": ["Highlights"],
        "m_keywords": ["World Series"],
        "limit": 150
    }
}

def clean_title_for_t(title):
    # টাইটেল থেকে অপ্রয়োজনীয় সব শব্দ বাদ দিয়ে শুধু টিমের নাম রাখা
    clean = re.sub(r'\|.*|Full Game|Highlights|NBA|NFL|NHL|MLB|Game|Recap|Condensed', '', title, flags=re.IGNORECASE)
    return clean.strip()

def format_duration(sec):
    if not sec: return "00:00"
    m, s = divmod(int(sec), 60)
    return f"{m:02d}:{s:02d}"

def update_db():
    file_path = 'data.json'
    if not os.path.exists(file_path):
        print("Error: data.json খুঁজে পাওয়া যায়নি!")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        db = json.load(f)

    # yt-dlp সেটিংস
    ydl_opts = {'playlistend': 50, 'extract_flat': True, 'quiet': True}

    for league in db['l']:
        l_id = league['id']
        
        # যদি এই লিগটি আমাদের কনফিগারেশনে থাকে
        if l_id in CONFIG:
            conf = CONFIG[l_id]
            print(f"Processing: {league['n']}...")
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                try:
                    result = ydl.extract_info(conf['url'], download=False)
                    existing_ids = {v['id'] for v in league['v']}
                    new_videos = []

                    if 'entries' in result:
                        # নতুন থেকে পুরনো হিসেবে ভিডিও চেক করা
                        for entry in result['entries']:
                            v_id = entry.get('id')
                            title = entry.get('title', '')

                            # ১. পজিটিভ কি-ওয়ার্ড ফিল্টার
                            if any(k.lower() in title.lower() for k in conf['kw']) and v_id not in existing_ids:
                                
                                # ২. m (Match Numbering) লজিক
                                m_val = ""
                                # টাইটেলে বিশেষ কি-ওয়ার্ড থাকলে সেটা বসবে
                                for mk in conf['m_keywords']:
                                    if mk.lower() in title.lower():
                                        m_val = mk
                                        break
                                
                                # না থাকলে নাম্বারিং (নিচ থেকে উপরে)
                                if not m_val:
                                    current_count = len(league['v']) + len(new_videos) + 1
                                    m_val = f"Match {current_count}"

                                new_videos.append({
                                    "m": m_val,
                                    "d": datetime.now().strftime("%d %b"),
                                    "t": clean_title_for_t(title),
                                    "id": v_id,
                                    "dur": format_duration(entry.get('duration'))
                                })

                    # নতুনগুলো শুরুতে যোগ করা
                    league['v'] = (new_videos[::-1] + league['v'])[:conf['limit']]
                except Exception as e:
                    print(f"Error updating {l_id}: {e}")

    # ফাইল সেভ করা
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(db, f, ensure_ascii=False, indent=2)
    print("Database updated successfully!")

if __name__ == "__main__":
    update_db()
