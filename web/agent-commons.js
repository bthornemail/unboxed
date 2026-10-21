const WIDTH = 640;
const HEIGHT = 360;
const AUDIO_RATE = 48000;
const AUDIO_FRAMES = 2048;

function rotl16(value, amount) {
  return ((value << amount) | (value >>> (16 - amount))) & 0xffff;
}

// This is the browser projection of the law checked exhaustively by the
// BusyBox probe. The UI must not become a second, incompatible state engine.
export function nextState(value) {
  return (rotl16(value, 1) ^ rotl16(value, 3) ^ rotl16(value, 14) ^ 0x1d1d) & 0xffff;
}

export class AgentCommons extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          min-height: 100vh;
          box-sizing: border-box;
          padding: 2rem;
          color: #d7fff5;
          background: #071013;
          font: 14px/1.4 ui-monospace, SFMono-Regular, Consolas, monospace;
        }
        main { max-width: 720px; margin: auto; }
        h1 { color: #72ffe0; font-size: 1.2rem; }
        canvas {
          display: block;
          width: 100%;
          max-width: ${WIDTH}px;
          aspect-ratio: 16 / 9;
          border: 1px solid #23695d;
          background: #020607;
          transform-origin: center;
        }
        button {
          margin: 1rem 0;
          padding: .6rem .8rem;
          color: #071013;
          background: #72ffe0;
          border: 0;
          cursor: pointer;
          font: inherit;
        }
        output { display: block; color: #9bcfc4; white-space: pre-wrap; }
      </style>
      <main>
        <h1>Unboxed State Commons</h1>
        <canvas width="${WIDTH}" height="${HEIGHT}"></canvas>
        <button type="button" data-step>Advance State</button>
        <button type="button" data-render>Render Offline Audio</button>
        <output data-readout>Initializing...</output>
        <video muted playsinline hidden></video>
      </main>
    `;
    this.canvas = this.shadowRoot.querySelector('canvas');
    this.readout = this.shadowRoot.querySelector('[data-readout]');
    this.video = this.shadowRoot.querySelector('video');
    this.state = 1;
    this.frame = 0;
    this.offscreen = typeof OffscreenCanvas === 'function'
      ? new OffscreenCanvas(WIDTH, HEIGHT)
      : null;
    this.drawContext = this.offscreen
      ? this.offscreen.getContext('2d')
      : this.canvas.getContext('2d');
    this.visibleContext = this.canvas.getContext('2d');
  }

  connectedCallback() {
    this.shadowRoot.querySelector('[data-step]')
      .addEventListener('click', () => this.advance());
    this.shadowRoot.querySelector('[data-render]')
      .addEventListener('click', () => this.renderOfflineAudio());
    this.installTextTrack();
    this.draw();
  }

  installTextTrack() {
    if (!this.video.textTracks || typeof VTTCue !== 'function') {
      return;
    }
    this.track = this.video.addTextTrack('metadata', 'state cues', 'en');
    this.track.mode = 'hidden';
    this.track.addEventListener('cuechange', () => {
      const cue = this.track.activeCues && this.track.activeCues[0];
      if (cue) this.readout.textContent = `Text cue: ${cue.text}`;
    });
  }

  publishCue() {
    if (!this.track) return;
    while (this.track.cues.length) this.track.removeCue(this.track.cues[0]);
    const seconds = this.frame / 60;
    const cue = new VTTCue(seconds, seconds + 1 / 60, JSON.stringify({
      frame: this.frame,
      state: this.state,
      fano: this.state & 0x7f,
    }));
    this.track.addCue(cue);
  }

  draw() {
    const ctx = this.drawContext;
    const phase = this.state & 0x7f;
    const angle = (phase % 7) * (Math.PI * 2 / 7);
    const scale = 1 + ((this.state >>> 4) % 12) / 24;
    const matrix = typeof DOMMatrix === 'function'
      ? new DOMMatrix().rotate((angle * 180) / Math.PI).scale(scale)
      : null;

    ctx.clearRect(0, 0, WIDTH, HEIGHT);
    ctx.fillStyle = '#020607';
    ctx.fillRect(0, 0, WIDTH, HEIGHT);
    ctx.strokeStyle = `hsl(${this.state % 240} 100% 65%)`;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(WIDTH / 2, HEIGHT / 2, 110 + phase, 0, Math.PI * 2);
    ctx.stroke();
    ctx.fillStyle = '#72ffe0';
    ctx.font = '14px monospace';
    ctx.fillText(`state 0x${this.state.toString(16).padStart(4, '0')}`, 24, 32);
    ctx.fillText(`fano ${phase}`, 24, 54);
    this.canvas.style.transform = matrix
      ? `matrix(${matrix.a}, ${matrix.b}, ${matrix.c}, ${matrix.d}, ${matrix.e}, ${matrix.f})`
      : `rotate(${(angle * 180) / Math.PI}deg) scale(${scale})`;

    if (this.offscreen) {
      this.visibleContext.clearRect(0, 0, WIDTH, HEIGHT);
      this.visibleContext.drawImage(this.offscreen, 0, 0);
    }
    this.publishCue();
    this.readout.textContent = `frame ${this.frame} | state 0x${this.state.toString(16).padStart(4, '0')} | fano ${phase}`;
  }

  advance() {
    this.state = nextState(this.state);
    this.frame += 1;
    this.draw();
  }

  async renderOfflineAudio() {
    if (typeof OfflineAudioContext !== 'function') {
      this.readout.textContent = 'OfflineAudioContext is unavailable in this browser.';
      return;
    }
    const context = new OfflineAudioContext(1, AUDIO_FRAMES, AUDIO_RATE);
    const buffer = context.createBuffer(1, AUDIO_FRAMES, AUDIO_RATE);
    const samples = buffer.getChannelData(0);
    let state = this.state;
    for (let index = 0; index < samples.length; index += 1) {
      state = nextState(state);
      samples[index] = (state / 32767.5) - 1;
    }
    const source = context.createBufferSource();
    source.buffer = buffer;
    source.connect(context.destination);
    source.start();
    const rendered = await context.startRendering();
    this.readout.textContent = `offline audio rendered: ${rendered.length} frames | final state 0x${state.toString(16).padStart(4, '0')}`;
  }
}

customElements.define('agent-commons', AgentCommons);
