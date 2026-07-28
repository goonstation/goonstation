import { BooleanLike } from 'tgui-core/react';

import { HealthData } from '../common/health/type';

export interface HealthAnalyzerData extends HealthData {
  clumsy_scan: BooleanLike; // the things we do for clowns
  organ_scan_upgrade: BooleanLike;
  reagent_scan_upgrade: BooleanLike;
}
