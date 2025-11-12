# Surface Pro 4 - Start Here

**For**: Dad's Surface Pro 4
**Created**: November 9, 2025
**Purpose**: Fix network issues and keep the system running smoothly

---

## What's Going On?

Your Surface Pro 4 is having trouble connecting to the office network/domain. This is a common Windows issue that's usually easy to fix. We've also set up some tools to keep the computer running smoothly long-term.

---

## The Quick Fix (When Network Stops Working)

**What you'll notice:**
- Can't access shared folders
- Login is slow or uses "cached" credentials
- Network shows as "Public" instead of "Domain"

**The Fix** (takes 30 seconds):
1. Right-click the Windows Start button
2. Click "Windows PowerShell (Admin)"
3. Copy and paste this: `Restart-NetAdapter *`
4. Press Enter
5. Wait 10 seconds

That fixes it 90% of the time.

**If that doesn't work**, call IT or check the detailed guide: `QUICK_START_GUIDE.md`

---

## What We've Set Up For You

### 1. Automatic Logging
- Everything important is now logged to `C:\SystemLogs`
- If something breaks, we can look at the logs to see what happened
- No action needed - it just runs in the background

### 2. Daily Maintenance (Runs at 2 AM)
- Cleans up temporary files
- Checks if the network is working
- Updates virus protection
- You'll never see it - it just happens while you sleep

### 3. Investigation Report
We created a snapshot of your system in `C:\SystemLogs\Investigation-[date]`
This helps us understand what's installed and how things are configured.

---

## Important: Windows 10 End of Life

**What it means**: Microsoft stopped supporting Windows 10 on October 14, 2025.

**What that means for you:**
- No more security updates (your computer becomes less safe over time)
- Eventually, programs and websites will stop working with Windows 10

**Your options** (in order of recommendation):

### Option 1: Extended Security Updates (ESU) - Best for Now
- **Cost**: FREE (if you sign in with Microsoft account) or $30/year
- **What you get**: Security updates for 1 more year (until October 2026)
- **Recommendation**: Do this ASAP as a temporary fix
- **How**: Settings → Update & Security → Look for "Extended Security Updates"

### Option 2: Keep Using It (Not Recommended)
- **Cost**: Free
- **Risk**: Computer becomes vulnerable to viruses and hackers
- **Only do this if**: You use the computer offline (no internet) or for non-critical stuff

### Option 3: Get a New Computer (Best Long-Term)
- **Cost**: $500-$1000 for a new laptop
- **What you get**: Windows 11, full support until ~2033
- **Consider**: Surface Laptop 6 or Surface Pro 9 (similar to what you have now)

### Option 4: Switch to Linux (Technical, But Free)
- **Cost**: Free
- **Difficulty**: Moderate learning curve
- **Recommendation**: We can help you test this without changing anything first
- **Good if**: You mainly use web browser, email, and basic programs

**Our Recommendation**: Sign up for free ESU now (buys you a year), then decide what to do next.

---

## Surface Pro 4 Hardware Issues to Watch For

### Screen Flickering ("Flickergate")
- **What**: Screen starts flickering constantly
- **Cause**: Hardware defect (display controller failing)
- **Fix**: None - it's a hardware failure
- **What to do**: Use an external monitor, or replace the device
- **How common**: Affects many Surface Pro 4 devices (8-9 years old now)

### Battery Problems
- **What**: Won't hold charge, or battery is swollen (bulging)
- **Cause**: Battery degradation (8-9 years old)
- **Fix**: Battery replacement (difficult, requires tools) or use plugged in
- **IMPORTANT**: If battery is swollen, stop using it immediately (fire hazard)

---

## Monthly Checklist (Takes 5 Minutes)

Do these once a month to keep things running smoothly:

- [ ] Check disk space: Windows key → Type "This PC" → Look at C: drive
  - If below 20% free: Delete old files from Downloads folder
- [ ] Run Windows Update: Settings → Update & Security → Check for updates
- [ ] Check logs for errors: Open `C:\SystemLogs` → Look for red "ERROR" entries
- [ ] Restart the computer (if you haven't in a while)

---

## When to Call for Help

**Call IT immediately if:**
- Network/domain login completely stops working (and quick fix doesn't work)
- You see "trust relationship failed" error
- Can't access any shared folders or email

**Contact us if:**
- Screen starts flickering constantly
- Battery is swollen or won't charge
- Computer is extremely slow
- You want to discuss Windows 10 EOL options

**Can wait until convenient:**
- Disk space warnings
- Minor software issues
- Questions about the logs or maintenance

---

## Where to Find More Information

**For you (human-friendly)**:
- This file! Re-read as needed

**For tech support / detailed troubleshooting**:
- `QUICK_START_GUIDE.md` - Step-by-step fixes with PowerShell commands
- `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` - Complete network troubleshooting
- `WINDOWS_10_EOL_ISSUES.md` - Everything about Windows 10 end-of-life

**System logs** (for troubleshooting):
- `C:\SystemLogs\system-log-[month].log` - General activity log
- `C:\SystemLogs\maintenance-log-[month].log` - Daily maintenance results
- `C:\SystemLogs\Investigation-[date]\` - System investigation reports

---

## Summary

**Right Now:**
- Network issues can usually be fixed by restarting network adapters (see "Quick Fix" above)
- System is logging everything to help troubleshoot future issues
- Daily maintenance runs automatically at 2 AM

**Next 3 Months:**
- Sign up for Extended Security Updates (free or $30) to extend Windows 10 support
- Monitor for hardware issues (screen flickering, battery problems)

**Next 6-12 Months:**
- Decide on long-term solution:
  - New Windows 11 computer ($500-$1000)
  - Try Linux (free, but learning curve)
  - Keep using Windows 10 (risky, but possible)

**Questions?** Contact IT support or refer to the detailed guides in this folder.

---

**Last Updated**: November 9, 2025
**Next Review**: Check back in 3 months (February 2026)
