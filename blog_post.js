const posts = [
  {
    id: 1,
    date: "April 2026",
    title: "Has CBS coverage of Trump actually softened? The data suggests yes.",
    tag: "Analysis",
    excerpt: "Beyond the high-profile editorial decisions at CBS, has the network's overall tone toward the president actually changed? We find that coverage noticeably softened following David Ellison's takeover of Paramount.",
    content: `
      <p>In recent months, a series of high-profile decisions at CBS has raised questions about the network's editorial independence. Following David Ellison's takeover of Paramount and the appointment of Bari Weiss as CBS News editor-in-chief, several stories have raised eyebrows: CBS pulled a 60 Minutes investigation into alleged abuses at El Salvador's CECOT prison, and Late Show host Stephen Colbert accused the network of blocking his interview with Texas Democratic Senate candidate James Talarico.</p>
      <p>But beyond these high-profile moments, has the network's overall tone toward the president actually changed? To answer this question, we examine CBS coverage before and after David Ellison took over Paramount and CBS. We find that coverage of the president noticeably softened following Ellison's takeover of the network.</p>
      <p>To examine TV coverage of Trump, we collected a year's worth of transcripts from CBS, ABC, CNN, Fox News, MSNBC/MS NOW, and NBC broadcasts. We break the transcripts into "blocks" of several sentences each and pull out all blocks mentioning Donald Trump. Then we classify each block as positive, negative, or neutral towards Trump using a text classification model trained on thousands of politics-related documents. Importantly, we use the model to measure the "stance" of the segments towards Trump — their position on whether he is performing well or not — rather than general sentiment. We then calculate "net coverage," defined as the percentage of positive minus negative blocks, and track how it shifted at each network before and after David Ellison took over Paramount and CBS (August 7, 2025).</p>
      <p>Before the Ellison takeover, net coverage of Trump on CBS was -13.1%, only slightly less negative than CNN in the same period (-15.7%). After CBS changed hands, net coverage shifted to be about 5 percentage points more positive, to -8.2%. Another way to think about it: before the takeover, roughly 1 in 4 CBS segments mentioning Trump were critical in tone. After, that fell to closer to 1 in 6.</p>
      <p>The gap in net coverage between CNN and CBS nearly tripled, going from 2.6 points to 7.6 points; whereas the gap between Fox News and CBS decreased by about 35%, going from 14.2 points to only 9.2 points. Put plainly, CBS became significantly less like CNN and significantly more like Fox News in its coverage of Trump after the ownership change.</p>

      <div style="margin: 36px 0; font-family: 'IBM Plex Sans', sans-serif;">
        <div style="font-weight: 600; font-size: 14px; margin-bottom: 4px;">Net Trump Coverage: Pre vs. Post-Ellison by Network</div>
        <div style="font-size: 12px; color: #888; margin-bottom: 20px;">Net coverage = % Positive minus % Negative</div>
        <div style="display: grid; grid-template-columns: repeat(6, 1fr); gap: 2px; background: #e0e0e0; border: 1px solid #e0e0e0; border-radius: 4px; overflow: hidden;">
          ${[
            {label: 'ABC',        pre: -12.4, post: -7.9},
            {label: 'CBS',        pre: -13.1, post: -8.2},
            {label: 'CNN',        pre: -15.7, post: -15.8},
            {label: 'Fox',        pre: 1.1,   post: 1.0},
            {label: 'MSNBC',      pre: -20.5, post: -24.9},
            {label: 'NBC',        pre: -2.3,  post: -1.6}
          ].map(d => {
            const maxAbs = 26;
            const totalH = 120;
            const preH = Math.round(Math.abs(d.pre) / maxAbs * totalH);
            const postH = Math.round(Math.abs(d.post) / maxAbs * totalH);
            const isPrePos = d.pre >= 0;
            const isPostPos = d.post >= 0;
            return `
              <div style="background:#fff;padding:10px 8px 8px;">
                <div style="font-weight:600;font-size:11px;text-align:center;padding:4px;background:#f0f0f0;margin-bottom:12px;border-radius:2px;">${d.label}</div>
                <div style="display:flex;align-items:flex-end;justify-content:center;gap:6px;height:${totalH}px;position:relative;">
                  <div style="display:flex;flex-direction:column;align-items:center;justify-content:flex-end;height:100%;">
                    ${isPrePos ? `<div style="font-size:9px;font-weight:600;color:#555;margin-bottom:2px;">${d.pre}%</div>` : ''}
                    <div style="width:28px;height:${preH}px;background:#9aa5b4;"></div>
                    ${!isPrePos ? `<div style="font-size:9px;font-weight:600;color:#555;margin-top:2px;">${d.pre}%</div>` : ''}
                  </div>
                  <div style="display:flex;flex-direction:column;align-items:center;justify-content:flex-end;height:100%;">
                    ${isPostPos ? `<div style="font-size:9px;font-weight:600;color:#1d4ed8;margin-bottom:2px;">${d.post}%</div>` : ''}
                    <div style="width:28px;height:${postH}px;background:#2563eb;"></div>
                    ${!isPostPos ? `<div style="font-size:9px;font-weight:600;color:#1d4ed8;margin-top:2px;">${d.post}%</div>` : ''}
                  </div>
                </div>
                <div style="border-top:2px solid #333;margin-top:0;"></div>
              </div>`;
          }).join('')}
        </div>
        <div style="display:flex;gap:20px;margin-top:10px;font-size:11px;color:#555;align-items:center;">
          <div style="display:flex;align-items:center;gap:6px;"><div style="width:12px;height:12px;background:#9aa5b4;border-radius:2px;"></div> Pre-Ellison (Jan 20 – Aug 6)</div>
          <div style="display:flex;align-items:center;gap:6px;"><div style="width:12px;height:12px;background:#2563eb;border-radius:2px;"></div> Post-Ellison (Aug 7 – Jan 20)</div>
        </div>
      </div>

      <p>To understand the magnitude of the shift, consider the full range of broadcast coverage we measure. Across networks, Fox News provides the most favorable coverage of Trump while MSNBC/MS NOW provides the most critical. The difference between Fox News and MSNBC/MS NOW net coverage in the pre-period was about 21 percentage points. So a 5-point shift in net coverage is about a quarter of the entire spectrum of TV coverage, all happening within the course of just a few months. None of the other networks saw a comparable "softening", with one exception: ABC, which also faced pressure from the FCC around the same time that Ellison took over CBS.</p>
      <p>We also break this down by CBS show, to see which particular broadcasts began to cover Trump more positively after the Ellison takeover. 60 Minutes, CBS Evening News, and CBS News Mornings saw the biggest positive changes in Trump-related coverage. Face the Nation, on the other hand, has become slightly more negative in its coverage of Trump post-Ellison takeover, while CBS News Sunday Morning has stayed roughly the same.</p>

      <div style="margin: 36px 0; font-family: 'IBM Plex Sans', sans-serif;">
        <div style="font-weight: 600; font-size: 14px; margin-bottom: 4px;">Net Trump Coverage by CBS Show: Pre vs. Post-Ellison</div>
        <div style="font-size: 12px; color: #888; margin-bottom: 20px;">Net coverage = % Positive minus % Negative</div>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 2px; background: #e0e0e0; border: 1px solid #e0e0e0; border-radius: 4px; overflow: hidden;">
          ${[
            {label: '60 Minutes',           pre: -14.3, post: 9.8},
            {label: 'CBS Evening News',      pre: -13.9, post: -6.0},
            {label: 'CBS News Sunday Morn.', pre: -13.5, post: -13.0},
            {label: 'CBS News Mornings',     pre: -11.2, post: -4.8},
            {label: 'CBS News Roundup',      pre: -13.8, post: -9.4},
            {label: 'Face the Nation',       pre: -15.6, post: -18.1}
          ].map(d => {
            const maxAbs = 20;
            const totalH = 100;
            const preH = Math.round(Math.abs(d.pre) / maxAbs * totalH);
            const postH = Math.round(Math.abs(d.post) / maxAbs * totalH);
            const isPrePos = d.pre >= 0;
            const isPostPos = d.post >= 0;
            return `
              <div style="background:#fff;padding:10px 8px 8px;">
                <div style="font-weight:600;font-size:10px;text-align:center;padding:4px;background:#f0f0f0;margin-bottom:12px;border-radius:2px;line-height:1.3;">${d.label}</div>
                <div style="display:flex;align-items:flex-end;justify-content:center;gap:6px;height:${totalH}px;">
                  <div style="display:flex;flex-direction:column;align-items:center;justify-content:flex-end;height:100%;">
                    ${isPrePos ? `<div style="font-size:9px;font-weight:600;color:#555;margin-bottom:2px;">${d.pre}%</div>` : ''}
                    <div style="width:28px;height:${preH}px;background:#9aa5b4;"></div>
                    ${!isPrePos ? `<div style="font-size:9px;font-weight:600;color:#555;margin-top:2px;">${d.pre}%</div>` : ''}
                  </div>
                  <div style="display:flex;flex-direction:column;align-items:center;justify-content:flex-end;height:100%;">
                    ${isPostPos ? `<div style="font-size:9px;font-weight:600;color:#1d4ed8;margin-bottom:2px;">${d.post}%</div>` : ''}
                    <div style="width:28px;height:${postH}px;background:#2563eb;"></div>
                    ${!isPostPos ? `<div style="font-size:9px;font-weight:600;color:#1d4ed8;margin-top:2px;">${d.post}%</div>` : ''}
                  </div>
                </div>
                <div style="border-top:2px solid #333;margin-top:0;"></div>
              </div>`;
          }).join('')}
        </div>
        <div style="display:flex;gap:20px;margin-top:10px;font-size:11px;color:#555;align-items:center;">
          <div style="display:flex;align-items:center;gap:6px;"><div style="width:12px;height:12px;background:#9aa5b4;border-radius:2px;"></div> Pre-Ellison (Jan 20 – Aug 6)</div>
          <div style="display:flex;align-items:center;gap:6px;"><div style="width:12px;height:12px;background:#2563eb;border-radius:2px;"></div> Post-Ellison (Aug 7 – Jan 20)</div>
        </div>
      </div>

      <p>The data here suggests that beyond the isolated moments we hear about in the news, something broader is happening at CBS. Coverage of the president has measurably shifted, not just in individual editorial decisions, but in the overall tone of how the network covers Trump day to day.</p>
    `
  }
];
