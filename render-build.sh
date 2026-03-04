#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

# Build worldmonitor embed only if the app is present (has index.html)
if [ -f worldmonitor/index.html ]; then
  echo "Building worldmonitor embed..."
  (cd worldmonitor && npm ci && npx cross-env VITE_MAP_ONLY=1 VITE_EMBED_BASE=/worldmonitor/ npx vite build)
  (cd ong_monitoring_dashboard && npm run worldmonitor:copy)
else
  echo "worldmonitor/index.html not found — creating stub so dashboard build can run."
  echo "To embed the map, add the full worldmonitor app (index.html, src/, vite.config.ts, etc.) to the worldmonitor/ folder."
  mkdir -p worldmonitor/dist
  echo '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Map</title></head><body><p>Map not built. Add worldmonitor app files to worldmonitor/ and redeploy.</p><script>window.location.href="https://www.worldmonitor.app/";</script></body></html>' > worldmonitor/dist/index.html
  (cd ong_monitoring_dashboard && node -e "
    const fs=require('fs');
    const p=require('path');
    const src=p.join(process.cwd(),'../worldmonitor/dist');
    const dest=p.join(process.cwd(),'public/worldmonitor');
    fs.rmSync(dest,{recursive:true,force:true});
    fs.cpSync(src,dest,{recursive:true});
    console.log('Copied worldmonitor stub to public/worldmonitor');
  ")
fi

echo "Building dashboard..."
cd ong_monitoring_dashboard && npm ci && npx vite build
echo "Build complete. Output: ong_monitoring_dashboard/dist"
