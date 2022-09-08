/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { block, element } from 'common/bem';

export const Block = 'cyborg-module-rewriter-interface';

export const ModuleView = block(Block, 'module-view');
export const ToolLabel = element(ModuleView, 'tool-label');

export const EmptyPlaceholder = block(Block, 'empty-placeholder');
