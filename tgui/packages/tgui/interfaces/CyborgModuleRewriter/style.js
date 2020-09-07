/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { block, element } from 'common/bem';

export const BlockCn = 'cyborg-module-rewriter-interface';

export const ModuleViewCn = block(BlockCn, 'module-view');
export const ToolLabelCn = element(ModuleViewCn, 'tool-label');

export const EmptyPlaceholderCn = block(BlockCn, 'empty-placeholder');
