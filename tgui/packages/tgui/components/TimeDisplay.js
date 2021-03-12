import { toFixed } from 'common/math';
import { Component } from 'inferno';

// AnimatedNumber Copypaste
const isSafeNumber = value => {
  return typeof value === 'number'
    && Number.isFinite(value)
    && !Number.isNaN(value);
};

export class TimeDisplay extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.timing = false;
    this.format = null;
    this.last_seen_value = undefined;
    this.state = {
      value: 0,
    };
    // Set initial state with value provided in props
    if (isSafeNumber(props.value)) {
      this.state.value = Number(props.value);
      this.last_seen_value = Number(props.value);
    }
  }

  componentDidUpdate() {
    if (this.props.timing) {
      clearInterval(this.timer);
      this.timer = setInterval(() => this.tick(), 1000); // every 1 s
    }
  }

  tick() {
    let current = Number(this.state.value);
    if (this.props.value !== this.last_seen_value) {
      this.last_seen_value = this.props.value;
      current = this.props.value;
    }
    const mod = this.props.auto === "up" ? 10 : -10; // Time down by default.
    const value = Math.max(0, current + mod); // one sec tick
    this.setState({ value });
  }

  componentDidMount() {
    if (this.props.timing) {
      this.timer = setInterval(() => this.tick(), 1000); // every 1 s
    }
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  static getDerivedStateFromProps(nextProps) {
    if (nextProps.timing) {
      return null;
    }
    return { value: nextProps.value };
  }

  static defaultFormat(value) {
    const seconds = toFixed(Math.floor((value/10) % 60)).padStart(2, "0");
    const minutes = toFixed(Math.floor((value/(10*60)) % 60)).padStart(2, "0");
    const hours = toFixed(Math.floor((value/(10*60*60)) % 24)).padStart(2, "0");
    return `${hours}:${minutes}:${seconds}`;
  }

  render() {
    const val = this.state.value;

    // Directly display weird stuff
    if (!isSafeNumber(val)) {
      return this.state.value || null;
    }

    if (this.props.format) {
      return this.props.format(val);
    } else {
      return TimeDisplay.defaultFormat(val);
    }
  }
}
