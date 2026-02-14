#!/usr/bin/env bash
#
# voice-to-claude.sh
#
# Records your voice, transcribes it with OpenAI Whisper, and sends
# the transcribed text to Claude Code as a prompt.
#
# Usage:
#   ./voice-to-claude.sh                  # Record, transcribe, send to Claude
#   ./voice-to-claude.sh --duration 10    # Record for 10 seconds (default: 5)
#   ./voice-to-claude.sh --lang nl        # Set Whisper language to Dutch
#   ./voice-to-claude.sh --model base     # Use a specific Whisper model
#   ./voice-to-claude.sh --dry-run        # Transcribe only, don't send to Claude
#
# Requirements:
#   - Python 3 with openai-whisper installed (pip install openai-whisper)
#   - ffmpeg
#   - Audio input device (microphone)
#   - Claude Code CLI (claude)

set -euo pipefail

# Defaults
DURATION=5
LANG="en"
MODEL="base"
DRY_RUN=false
AUDIO_DIR="/tmp/voice-to-claude"
mkdir -p "$AUDIO_DIR"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --duration|-d)  DURATION="$2"; shift 2 ;;
        --lang|-l)      LANG="$2"; shift 2 ;;
        --model|-m)     MODEL="$2"; shift 2 ;;
        --dry-run)      DRY_RUN=true; shift ;;
        --help|-h)
            echo "Usage: voice-to-claude.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --duration SEC   Recording duration in seconds (default: 5)"
            echo "  -l, --lang LANG      Whisper language code (default: en)"
            echo "                       Examples: en, nl, de, fr, es, ja, zh"
            echo "  -m, --model MODEL    Whisper model size (default: base)"
            echo "                       Options: tiny, base, small, medium, large"
            echo "  --dry-run            Only transcribe, don't send to Claude"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
AUDIO_FILE="$AUDIO_DIR/recording_${TIMESTAMP}.wav"
TEXT_FILE="$AUDIO_DIR/recording_${TIMESTAMP}.txt"

# Check dependencies
check_dep() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: '$1' is not installed."
        echo "Install it with: $2"
        exit 1
    fi
}

check_dep "whisper" "pip install openai-whisper"
check_dep "ffmpeg" "apt-get install ffmpeg / brew install ffmpeg"
check_dep "claude" "npm install -g @anthropic-ai/claude-code"

# Detect recording tool
record_audio() {
    echo "🎤 Recording for ${DURATION} seconds... (speak now!)"
    echo "   Press Ctrl+C to stop early."

    if command -v arecord &>/dev/null; then
        arecord -f cd -t wav -d "$DURATION" "$AUDIO_FILE" 2>/dev/null
    elif command -v sox &>/dev/null; then
        sox -d -r 16000 -c 1 -b 16 "$AUDIO_FILE" trim 0 "$DURATION" 2>/dev/null
    elif command -v ffmpeg &>/dev/null; then
        # Try common audio inputs
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS: use avfoundation
            ffmpeg -y -f avfoundation -i ":default" -t "$DURATION" -ar 16000 -ac 1 "$AUDIO_FILE" 2>/dev/null
        else
            # Linux: try pulseaudio, then alsa
            ffmpeg -y -f pulse -i default -t "$DURATION" -ar 16000 -ac 1 "$AUDIO_FILE" 2>/dev/null || \
            ffmpeg -y -f alsa -i default -t "$DURATION" -ar 16000 -ac 1 "$AUDIO_FILE" 2>/dev/null
        fi
    else
        echo "Error: No audio recording tool found."
        echo "Install one of: arecord (alsa-utils), sox, or ffmpeg"
        exit 1
    fi

    echo "   Recording saved: $AUDIO_FILE"
}

# Transcribe with Whisper
transcribe_audio() {
    echo ""
    echo "🔄 Transcribing with Whisper (model: ${MODEL}, language: ${LANG})..."

    whisper "$AUDIO_FILE" \
        --model "$MODEL" \
        --language "$LANG" \
        --output_format txt \
        --output_dir "$AUDIO_DIR" \
        --fp16 False \
        2>/dev/null

    # Whisper outputs <filename>.txt
    local base
    base=$(basename "$AUDIO_FILE" .wav)
    mv "$AUDIO_DIR/${base}.txt" "$TEXT_FILE" 2>/dev/null || true

    if [[ ! -f "$TEXT_FILE" ]] || [[ ! -s "$TEXT_FILE" ]]; then
        echo "Error: Transcription produced no output."
        exit 1
    fi

    TRANSCRIBED=$(cat "$TEXT_FILE")
    echo "📝 Transcription: \"$TRANSCRIBED\""
}

# Send to Claude
send_to_claude() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        echo "🏁 Dry run - not sending to Claude."
        echo "   Text: $TRANSCRIBED"
        return
    fi

    echo ""
    echo "🚀 Sending to Claude Code..."
    echo "────────────────────────────────────────"
    claude --print "$TRANSCRIBED"
    echo "────────────────────────────────────────"
}

# Cleanup old recordings (keep last 20)
cleanup() {
    local count
    count=$(ls -1 "$AUDIO_DIR"/recording_*.wav 2>/dev/null | wc -l)
    if [[ "$count" -gt 20 ]]; then
        ls -1t "$AUDIO_DIR"/recording_*.wav | tail -n +21 | xargs rm -f
        ls -1t "$AUDIO_DIR"/recording_*.txt | tail -n +21 | xargs rm -f
    fi
}

# Main
record_audio
transcribe_audio
send_to_claude
cleanup

echo ""
echo "Done! Audio: $AUDIO_FILE | Text: $TEXT_FILE"
