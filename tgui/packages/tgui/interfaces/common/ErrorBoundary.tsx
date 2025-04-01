/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import {
  Component,
  type ComponentType,
  type ErrorInfo,
  type PropsWithChildren,
} from 'react';

export interface ErrorFallbackProps {
  error: unknown;
}

type Props = PropsWithChildren<{
  FallbackComponent: ComponentType<ErrorFallbackProps>;
}>;

interface State {
  hasError: boolean;
  lastError: unknown;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      lastError: null,
      hasError: false,
    };
  }

  static getDerivedStateFromError(error: unknown) {
    return {
      hasError: true,
      lastError: error,
    };
  }

  componentDidCatch(error: unknown, info: ErrorInfo) {
    // TODO: better runtime logging
  }

  render() {
    const { children, FallbackComponent } = this.props;
    const { lastError, hasError } = this.state;
    if (hasError) {
      return <FallbackComponent error={lastError} />;
    }
    return children;
  }
}
