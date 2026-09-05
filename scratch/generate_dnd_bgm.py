import math
import struct
import wave

def generate_dnd_bgm(output_path="assets/audio/bgm_dungeon.wav", sample_rate=22050, duration=16.0):
    bpm = 60.0
    total_samples = int(sample_rate * duration)
    # Stereo buffers
    left_channel = [0.0] * total_samples
    right_channel = [0.0] * total_samples

    # Notes frequencies (D minor)
    D2 = 73.42
    A2 = 110.00
    D3 = 146.83
    F3 = 174.61
    G3 = 196.00
    A3 = 220.00
    Bb3 = 233.08
    C4 = 261.63
    D4 = 293.66
    F4 = 349.23

    # 1. DRONE BASS LAYER (Continuous deep atmospheric sound, seamless loop)
    # Sum of harmonically related sines with slow LFO modulation
    for i in range(total_samples):
        t = i / sample_rate
        # LFOs for organic movement that loop perfectly over 16s
        # 16s = 1 cycle of 1/16 Hz = 0.0625 Hz
        lfo1 = 0.8 + 0.2 * math.sin(2 * math.pi * 0.125 * t)  # 2 cycles in 16s
        lfo2 = 0.8 + 0.2 * math.cos(2 * math.pi * 0.250 * t)  # 4 cycles in 16s
        
        # Sub drone D2 (73.42 Hz)
        sub = 0.35 * math.sin(2 * math.pi * D2 * t)
        # Low cello drone D3 (146.83 Hz) with slight detuning for chorus width
        c_left = 0.22 * math.sin(2 * math.pi * D3 * t) + 0.12 * math.sin(2 * math.pi * (D3 * 1.003) * t)
        c_right = 0.22 * math.sin(2 * math.pi * D3 * t) + 0.12 * math.sin(2 * math.pi * (D3 * 0.997) * t)
        # Fifth harmonic A2 (110 Hz)
        fifth = 0.18 * math.sin(2 * math.pi * A2 * t) * lfo1
        # Minor third F3 (174.61 Hz) subtle dark mystery
        third = 0.09 * math.sin(2 * math.pi * F3 * t) * lfo2

        drone_l = (sub + c_left + fifth + third) * 0.55
        drone_r = (sub + c_right + fifth + third) * 0.55

        left_channel[i] += drone_l
        right_channel[i] += drone_r

    # 2. DUNGEON WAR DRUM / TIMPANI LAYER
    # Hits on beats: 0s, 2s, 4s, 6s, 8s, 10s, 12s, 14s (every 2 seconds)
    drum_hits = [
        (0.0, 1.0, 68.0),
        (2.0, 0.65, 78.0),
        (3.5, 0.45, 82.0),
        (4.0, 0.9, 68.0),
        (6.0, 0.7, 75.0),
        (8.0, 1.05, 65.0),
        (10.0, 0.65, 78.0),
        (11.5, 0.5, 82.0),
        (12.0, 0.95, 68.0),
        (14.0, 0.75, 72.0),
        (15.5, 0.4, 82.0),
    ]

    drum_duration = 1.4
    for hit_time, hit_vol, base_pitch in drum_hits:
        start_idx = int(hit_time * sample_rate)
        hit_len = int(drum_duration * sample_rate)
        for j in range(hit_len):
            idx = (start_idx + j) % total_samples
            dt = j / sample_rate
            # Exponential decay
            env = math.exp(-3.2 * dt)
            # Pitch drop (from 140Hz down to base_pitch)
            freq = base_pitch + (140.0 - base_pitch) * math.exp(-18.0 * dt)
            # Timpani body: fundamental + overtone + punch noise
            punch = math.sin(2 * math.pi * freq * dt)
            overtone = 0.3 * math.sin(2 * math.pi * freq * 1.62 * dt)
            # Subtle low rattle/skin noise
            noise = 0.08 * (math.sin(dt * 3341.0) % 1.0 - 0.5) * math.exp(-12.0 * dt)
            sample_val = (punch + overtone + noise) * env * hit_vol * 0.5

            left_channel[idx] += sample_val * 0.95
            right_channel[idx] += sample_val * 0.95

    # 3. MYSTIC HARP / ARCANUM BELL MELODY
    # Atmospheric, contemplative dark fantasy melody notes
    # (time, pitch, volume, pan: -1 left, 1 right)
    melody_notes = [
        (0.5, D4, 0.35, -0.3),
        (1.5, F4, 0.28, 0.3),
        (3.0, A3, 0.32, -0.2),
        (4.5, C4, 0.30, 0.2),
        (6.0, D4, 0.38, 0.0),
        (7.5, Bb3, 0.26, -0.4),
        (8.5, A3, 0.32, 0.3),
        (10.0, F3, 0.28, -0.2),
        (11.5, G3, 0.25, 0.4),
        (12.5, A3, 0.35, -0.1),
        (14.0, D4, 0.40, 0.1),
        (15.0, C4, 0.22, -0.3),
    ]

    note_decay = 2.0
    for note_time, note_pitch, note_vol, pan in melody_notes:
        start_idx = int(note_time * sample_rate)
        note_len = int(note_decay * sample_rate)
        for j in range(note_len):
            idx = (start_idx + j) % total_samples
            dt = j / sample_rate
            env = math.exp(-2.2 * dt)
            # Bell / harp harmonic structure: fundamental + 2nd + 3rd + 4.2x mystic chime
            h1 = math.sin(2 * math.pi * note_pitch * dt)
            h2 = 0.35 * math.sin(2 * math.pi * note_pitch * 2.0 * dt) * math.exp(-3.0 * dt)
            h3 = 0.18 * math.sin(2 * math.pi * note_pitch * 3.0 * dt) * math.exp(-4.5 * dt)
            h_chime = 0.15 * math.sin(2 * math.pi * note_pitch * 4.18 * dt) * math.exp(-6.0 * dt)
            
            sig = (h1 + h2 + h3 + h_chime) * env * note_vol * 0.45
            pan_l = 0.5 * (1.0 - pan)
            pan_r = 0.5 * (1.0 + pan)

            left_channel[idx] += sig * pan_l
            right_channel[idx] += sig * pan_r

            # Reverb echo delay at 350ms and 700ms
            d1 = int(0.35 * sample_rate)
            d2 = int(0.70 * sample_rate)
            idx_d1 = (idx + d1) % total_samples
            idx_d2 = (idx + d2) % total_samples
            left_channel[idx_d1] += sig * pan_r * 0.28
            right_channel[idx_d1] += sig * pan_l * 0.28
            left_channel[idx_d2] += sig * pan_l * 0.14
            right_channel[idx_d2] += sig * pan_r * 0.14

    # 4. Seamless loop cross-fade at boundaries (0.2 seconds) to avoid any clicks
    crossfade_len = int(0.25 * sample_rate)
    for k in range(crossfade_len):
        w = k / crossfade_len  # 0 to 1
        end_idx = total_samples - crossfade_len + k
        # blend beginning into end and end into beginning
        blended_l = left_channel[k] * w + left_channel[end_idx] * (1.0 - w)
        blended_r = right_channel[k] * w + right_channel[end_idx] * (1.0 - w)
        left_channel[k] = blended_l
        left_channel[end_idx] = blended_l
        right_channel[k] = blended_r
        right_channel[end_idx] = blended_r

    # Find peak for normalization
    peak = 0.0001
    for i in range(total_samples):
        al = abs(left_channel[i])
        ar = abs(right_channel[i])
        if al > peak:
            peak = al
        if ar > peak:
            peak = ar

    norm_factor = 0.88 / peak

    # Write WAV file
    with wave.open(output_path, 'wb') as wav_file:
        wav_file.setnchannels(2)
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)

        frames = bytearray()
        for i in range(total_samples):
            sl = max(-32767, min(32767, int(left_channel[i] * norm_factor * 32767)))
            sr = max(-32767, min(32767, int(right_channel[i] * norm_factor * 32767)))
            frames.extend(struct.pack('<hh', sl, sr))
        wav_file.writeframes(frames)

    print(f"Generated {output_path}: {duration}s, {sample_rate}Hz, 2-channel 16-bit PCM WAV. Peak: {peak:.3f}")

if __name__ == "__main__":
    generate_dnd_bgm()
