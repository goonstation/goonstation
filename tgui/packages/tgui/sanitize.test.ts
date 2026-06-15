import { describe, it } from 'vitest';

import { sanitizeDefAllowTags, sanitizeText } from './sanitize';

describe('sanitizeText', () => {
  it('should sanitize basic HTML input', ({ expect }) => {
    const input = '<b>Hello, world!</b><script>alert("hack")</script>';
    const expected = '<b>Hello, world!</b>';
    const result = sanitizeText(input);
    expect(result).toBe(expected);
  });

  it('should sanitize advanced HTML input when advHtml flag is true', ({
    expect,
  }) => {
    const input =
      '<b>Hello, world!</b><iframe src="https://example.com"></iframe>';
    const expected = '<b>Hello, world!</b>';
    const result = sanitizeText(input, true);
    expect(result).toBe(expected);
  });

  it('should allow specific HTML tags when tags array is provided', ({
    expect,
  }) => {
    const input = '<b>Hello, world!</b><span>Goodbye, world!</span>';
    const tags = ['b'];
    const expected = '<b>Hello, world!</b>Goodbye, world!';
    const result = sanitizeText(input, false, tags);
    expect(result).toBe(expected);
  });

  it('should allow advanced HTML tags when advTags array is provided and advHtml flag is true', ({
    expect,
  }) => {
    const input =
      '<b>Hello, world!</b><iframe src="https://example.com"></iframe>';
    const advTags = ['iframe'];
    const expected =
      '<b>Hello, world!</b><iframe src="https://example.com"></iframe>';
    const result = sanitizeText(input, true, undefined, undefined, advTags);
    expect(result).toBe(expected);
  });

  describe('paper sheet config (input tags + style allowed)', () => {
    const PAPER_ALLOWED_TAGS = [...sanitizeDefAllowTags, 'input'];
    const PAPER_FORBID_ATTRS = ['class', 'background'];

    it('strips script tags', ({ expect }) => {
      const input = '<b>hi</b><script>alert(1)</script>';
      const result = sanitizeText(
        input,
        false,
        PAPER_ALLOWED_TAGS,
        PAPER_FORBID_ATTRS,
      );
      expect(result).toBe('<b>hi</b>');
    });

    it('strips event handler attributes', ({ expect }) => {
      const input = '<b onclick="alert(1)">hi</b>';
      const result = sanitizeText(
        input,
        false,
        PAPER_ALLOWED_TAGS,
        PAPER_FORBID_ATTRS,
      );
      expect(result).toBe('<b>hi</b>');
    });

    it('strips javascript: hrefs', ({ expect }) => {
      const input = '<a href="javascript:alert(1)">click</a>';
      const result = sanitizeText(
        input,
        false,
        PAPER_ALLOWED_TAGS,
        PAPER_FORBID_ATTRS,
      );
      // <a> is not in PAPER_ALLOWED_TAGS so the tag itself is stripped too
      expect(result).not.toContain('javascript:');
    });

    it('preserves input tags with style, id, type, size, maxlength, disabled', ({
      expect,
    }) => {
      const input =
        '[<input type="text" style="color:red;min-width:50px;" id="paperfield_0" size="5" maxlength="5" disabled />]';
      const result = sanitizeText(
        input,
        false,
        PAPER_ALLOWED_TAGS,
        PAPER_FORBID_ATTRS,
      );
      expect(result).toContain('<input');
      expect(result).toContain('type="text"');
      expect(result).toContain('id="paperfield_0"');
      expect(result).toContain('style=');
      expect(result).toContain('disabled');
    });

    it('preserves inline style on span', ({ expect }) => {
      const input = '<span style="color:blue;font-family:Arial;">text</span>';
      const result = sanitizeText(
        input,
        false,
        PAPER_ALLOWED_TAGS,
        PAPER_FORBID_ATTRS,
      );
      expect(result).toContain('style=');
      expect(result).toContain('color:blue');
    });

    it('strips class attributes', ({ expect }) => {
      const input = '<span class="evil" style="color:red;">text</span>';
      const result = sanitizeText(
        input,
        false,
        PAPER_ALLOWED_TAGS,
        PAPER_FORBID_ATTRS,
      );
      expect(result).not.toContain('class=');
      expect(result).toContain('style=');
    });

    it('strips background attributes', ({ expect }) => {
      const input = '<div background="http://evil.com/x.png">text</div>';
      const result = sanitizeText(
        input,
        false,
        PAPER_ALLOWED_TAGS,
        PAPER_FORBID_ATTRS,
      );
      expect(result).not.toContain('background=');
    });
  });
});
