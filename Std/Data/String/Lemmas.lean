/-
Copyright (c) 2023 Bulhwi Cha. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bulhwi Cha
-/
import Std.Data.Char
import Std.Data.Nat.Lemmas
import Std.Data.List.Lemmas
import Std.Tactic.Ext.Attr
import Std.Tactic.Simpa

namespace String

@[ext] theorem ext {s₁ s₂ : String} (h : s₁.data = s₂.data) : s₁ = s₂ :=
  show ⟨s₁.data⟩ = (⟨s₂.data⟩ : String) from h ▸ rfl

theorem ext_iff {s₁ s₂ : String} : s₁ = s₂ ↔ s₁.data = s₂.data := ⟨fun h => h ▸ rfl, ext⟩

@[simp] theorem default_eq : default = "" := rfl

@[simp] theorem str_eq : str = push := rfl

@[simp] theorem mk_length (s : List Char) : (String.mk s).length = s.length := rfl

@[simp] theorem data_push (s : String) (c : Char) : (s.push c).1 = s.1 ++ [c] := rfl

@[simp] theorem data_append (s t : String) : (s ++ t).1 = s.1 ++ t.1 := rfl

attribute [simp] toList -- prefer `String.data` over `String.toList` in lemmas

theorem lt_iff (s t : String) : s < t ↔ s.1 < t.1 := .rfl

private theorem add_csize_pos : 0 < i + csize c :=
  Nat.add_pos_right _ (csize_pos c)

private theorem ne_add_csize_add_self : i ≠ n + csize c + i :=
  Nat.ne_of_lt (Nat.lt_add_of_pos_left add_csize_pos)

/-- The UTF-8 byte length of a list of characters. (This is intended for specification purposes.) -/
@[inline] def utf8Len : List Char → Nat := utf8ByteSize.go

@[simp] theorem utf8ByteSize.go_eq : utf8ByteSize.go = utf8Len := rfl

@[simp] theorem utf8ByteSize_mk (cs) : utf8ByteSize ⟨cs⟩ = utf8Len cs := rfl

@[simp] theorem utf8Len_nil : utf8Len [] = 0 := rfl

@[simp] theorem utf8Len_cons (c cs) : utf8Len (c :: cs) = utf8Len cs + csize c := rfl

@[simp] theorem utf8Len_append (cs₁ cs₂) : utf8Len (cs₁ ++ cs₂) = utf8Len cs₁ + utf8Len cs₂ := by
  induction cs₁ <;> simp [*, Nat.add_right_comm]

@[simp] theorem utf8Len_reverseAux (cs₁ cs₂) :
    utf8Len (cs₁.reverseAux cs₂) = utf8Len cs₁ + utf8Len cs₂ := by
  induction cs₁ generalizing cs₂ <;> simp [*, ← Nat.add_assoc, Nat.add_right_comm]

@[simp] theorem utf8Len_reverse (cs) : utf8Len cs.reverse = utf8Len cs := utf8Len_reverseAux ..

@[simp] theorem utf8Len_eq_zero : utf8Len l = 0 ↔ l = [] := by
  cases l <;> simp [Nat.ne_of_gt add_csize_pos]

section
open List
theorem utf8Len_le_of_sublist : ∀ {cs₁ cs₂}, cs₁ <+ cs₂ → utf8Len cs₁ ≤ utf8Len cs₂
  | _, _, .slnil => Nat.le_refl _
  | _, _, .cons _ h => Nat.le_trans (utf8Len_le_of_sublist h) (Nat.le_add_right ..)
  | _, _, .cons₂ _ h => Nat.add_le_add_right (utf8Len_le_of_sublist h) _

theorem utf8Len_le_of_infix (h : cs₁ <:+: cs₂) : utf8Len cs₁ ≤ utf8Len cs₂ :=
  utf8Len_le_of_sublist h.sublist

theorem utf8Len_le_of_suffix (h : cs₁ <:+ cs₂) : utf8Len cs₁ ≤ utf8Len cs₂ :=
  utf8Len_le_of_sublist h.sublist

theorem utf8Len_le_of_prefix (h : cs₁ <+: cs₂) : utf8Len cs₁ ≤ utf8Len cs₂ :=
  utf8Len_le_of_sublist h.sublist
end

@[simp] theorem endPos_eq (cs : List Char) : endPos ⟨cs⟩ = ⟨utf8Len cs⟩ := rfl

namespace Pos

@[simp] theorem byteIdx_zero : (0 : Pos).byteIdx = 0 := rfl

theorem byteIdx_mk (n : Nat) : byteIdx ⟨n⟩ = n := rfl

@[simp] theorem mk_zero : ⟨0⟩ = (0 : Pos) := rfl

@[simp] theorem mk_byteIdx (p : Pos) : ⟨p.byteIdx⟩ = p := rfl

@[ext] theorem ext {i₁ i₂ : Pos} (h : i₁.byteIdx = i₂.byteIdx) : i₁ = i₂ :=
  show ⟨i₁.byteIdx⟩ = (⟨i₂.byteIdx⟩ : Pos) from h ▸ rfl

theorem ext_iff {i₁ i₂ : Pos} : i₁ = i₂ ↔ i₁.byteIdx = i₂.byteIdx := ⟨fun h => h ▸ rfl, ext⟩

@[simp] theorem add_byteIdx (p₁ p₂ : Pos) : (p₁ + p₂).byteIdx = p₁.byteIdx + p₂.byteIdx := rfl

theorem add_eq (p₁ p₂ : Pos) : p₁ + p₂ = ⟨p₁.byteIdx + p₂.byteIdx⟩ := rfl

@[simp] theorem sub_byteIdx (p₁ p₂ : Pos) : (p₁ - p₂).byteIdx = p₁.byteIdx - p₂.byteIdx := rfl

theorem sub_eq (p₁ p₂ : Pos) : p₁ - p₂ = ⟨p₁.byteIdx - p₂.byteIdx⟩ := rfl

@[simp] theorem addChar_byteIdx (p : Pos) (c : Char) : (p + c).byteIdx = p.byteIdx + csize c := rfl

theorem addChar_eq (p : Pos) (c : Char) : p + c = ⟨p.byteIdx + csize c⟩ := rfl

theorem zero_addChar_byteIdx (c : Char) : ((0 : Pos) + c).byteIdx = csize c := by
  simp only [addChar_byteIdx, byteIdx_zero, Nat.zero_add]

theorem zero_addChar_eq (c : Char) : (0 : Pos) + c = ⟨csize c⟩ := by rw [← zero_addChar_byteIdx]

theorem addChar_right_comm (p : Pos) (c₁ c₂ : Char) : p + c₁ + c₂ = p + c₂ + c₁ := by
  apply ext
  repeat rw [pos_add_char]
  apply Nat.add_right_comm

theorem lt_addChar (p : Pos) (c : Char) : p < p + c := Nat.lt_add_of_pos_right (csize_pos _)

theorem ne_of_lt {i₁ i₂ : Pos} (h : i₁ < i₂) : i₁ ≠ i₂ := mt ext_iff.1 (Nat.ne_of_lt h)

theorem ne_of_gt {i₁ i₂ : Pos} (h : i₁ < i₂) : i₂ ≠ i₁ := (ne_of_lt h).symm

@[simp] theorem addString_byteIdx (p : Pos) (s : String) :
    (p + s).byteIdx = p.byteIdx + s.utf8ByteSize := rfl

theorem addString_eq (p : Pos) (s : String) : p + s = ⟨p.byteIdx + s.utf8ByteSize⟩ := rfl

theorem zero_addString_byteIdx (s : String) : ((0 : Pos) + s).byteIdx = s.utf8ByteSize := by
  simp only [addString_byteIdx, byteIdx_zero, Nat.zero_add]

private theorem zero_ne_addChar {i : Pos} {c : Char} : 0 ≠ i + c :=
  ne_of_lt add_csize_pos

theorem zero_addString_eq (s : String) : (0 : Pos) + s = ⟨s.utf8ByteSize⟩ := by
  rw [← zero_addString_byteIdx]

theorem le_iff {i₁ i₂ : Pos} : i₁ ≤ i₂ ↔ i₁.byteIdx ≤ i₂.byteIdx := .rfl

@[simp] theorem mk_le_mk {i₁ i₂ : Nat} : Pos.mk i₁ ≤ Pos.mk i₂ ↔ i₁ ≤ i₂ := .rfl

theorem lt_iff {i₁ i₂ : Pos} : i₁ < i₂ ↔ i₁.byteIdx < i₂.byteIdx := .rfl

@[simp] theorem mk_lt_mk {i₁ i₂ : Nat} : Pos.mk i₁ < Pos.mk i₂ ↔ i₁ < i₂ := .rfl

/-- A string position is valid if it is equal to the UTF-8 length of an initial substring of `s`. -/
def Valid (s : String) (p : Pos) : Prop :=
  ∃ cs cs', cs ++ cs' = s.1 ∧ p.1 = utf8Len cs

@[simp] theorem valid_zero : Valid s 0 := ⟨[], s.1, rfl, rfl⟩

@[simp] theorem valid_endPos : Valid s (endPos s) := ⟨s.1, [], by simp, rfl⟩

theorem Valid.mk (cs cs' : List Char) : Valid ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ := ⟨cs, cs', rfl, rfl⟩

theorem Valid.le_endPos : ∀ {s p}, Valid s p → p ≤ endPos s
  | ⟨_⟩, ⟨_⟩, ⟨cs, cs', rfl, rfl⟩ => by simp [Nat.le_add_right]

end Pos

theorem endPos_eq_zero : ∀ (s : String), endPos s = 0 ↔ s = ""
  | ⟨_⟩ => Pos.ext_iff.trans <| utf8Len_eq_zero.trans ext_iff.symm

theorem isEmpty_iff (s : String) : isEmpty s ↔ s = "" :=
  (beq_iff_eq ..).trans (endPos_eq_zero _)

/--
Induction along the valid positions in a list of characters.
(This definition is intended only for specification purposes.)
-/
def utf8InductionOn {motive : List Char → Pos → Sort u}
    (s : List Char) (i p : Pos)
    (nil : ∀ i, motive [] i)
    (eq  : ∀ c cs, motive (c :: cs) p)
    (ind : ∀ (c : Char) cs i, i ≠ p → motive cs (i + c) → motive (c :: cs) i) :
    motive s i :=
  match s with
  | [] => nil i
  | c::cs =>
    if h : i = p then
      h ▸ eq c cs
    else ind c cs i h (utf8InductionOn cs (i + c) p nil eq ind)

theorem utf8GetAux_add_right_cancel (s : List Char) (i p n : Nat) :
    utf8GetAux s ⟨i + n⟩ ⟨p + n⟩ = utf8GetAux s ⟨i⟩ ⟨p⟩ := by
  apply utf8InductionOn s ⟨i⟩ ⟨p⟩ (motive := fun s i =>
    utf8GetAux s ⟨i.byteIdx + n⟩ ⟨p + n⟩ = utf8GetAux s i ⟨p⟩) <;>
  simp [utf8GetAux]
  intro c cs ⟨i⟩ h ih
  simp [Pos.ext_iff, Pos.addChar_eq] at h ⊢
  simp [Nat.add_right_cancel_iff, h]
  rw [Nat.add_right_comm]
  exact ih

theorem utf8GetAux_addChar_right_cancel (s : List Char) (i p : Pos) (c : Char) :
    utf8GetAux s (i + c) (p + c) = utf8GetAux s i p := utf8GetAux_add_right_cancel ..

theorem utf8GetAux_of_valid (cs cs' : List Char) {i p : Nat} (hp : i + utf8Len cs = p) :
    utf8GetAux (cs ++ cs') ⟨i⟩ ⟨p⟩ = cs'.headD default := by
  match cs, cs' with
  | [], [] => rfl
  | [], c::cs' => simp [← hp, utf8GetAux]
  | c::cs, cs' =>
    simp [utf8GetAux, -List.headD_eq_head?]; rw [if_neg]
    case hnc => rw [← hp]; apply Pos.ne_of_lt (Nat.lt_add_of_pos_right add_csize_pos)
    refine utf8GetAux_of_valid cs cs' ?_
    simpa [Nat.add_assoc, Nat.add_comm] using hp

theorem get_of_valid (cs cs' : List Char) : get ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ = cs'.headD default :=
  utf8GetAux_of_valid _ _ (Nat.zero_add _)

theorem get_cons_addChar (c : Char) (cs : List Char) (i : Pos) :
    get ⟨c :: cs⟩ (i + c) = get ⟨cs⟩ i := by
  simp [get, utf8GetAux, Pos.zero_ne_addChar, utf8GetAux_addChar_right_cancel]

-- FIXME: Depends on lean4#2213
-- theorem utf8GetAux?_of_valid (cs cs' : List Char) {i p : Nat} (hp : i + utf8Len cs = p) :
--     utf8GetAux? (cs ++ cs') ⟨i⟩ ⟨p⟩ = cs'.head? := by
--   match cs, cs' with
--   | [], [] => rfl
--   | [], c::cs' => simp [← hp, utf8GetAux?]
--   | c::cs, cs' =>
--     simp [utf8GetAux?]; rw [if_neg]
--     case hnc => rw [← hp]; apply Pos.ne_of_lt (Nat.lt_add_of_pos_right add_csize_pos)
--     refine utf8GetAux?_of_valid cs cs' ?_
--     simpa [Nat.add_assoc, Nat.add_comm] using hp
--
-- theorem get?_of_valid (cs cs' : List Char) : get? ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ = cs'.head? :=
--   utf8GetAux?_of_valid _ _ (Nat.zero_add _)

@[simp] theorem get!_eq_get (s : String) (p : Pos) : get! s p = get s p := rfl

theorem utf8SetAux_of_valid (c' : Char) (cs cs' : List Char) {i p : Nat} (hp : i + utf8Len cs = p) :
    utf8SetAux c' (cs ++ cs') ⟨i⟩ ⟨p⟩ = cs ++ cs'.modifyHead fun _ => c' := by
  match cs, cs' with
  | [], [] => rfl
  | [], c::cs' => simp [← hp, utf8SetAux]
  | c::cs, cs' =>
    simp [utf8SetAux]; rw [if_neg]
    case hnc => rw [← hp]; apply Pos.ne_of_lt (Nat.lt_add_of_pos_right add_csize_pos)
    refine congrArg (c::·) (utf8SetAux_of_valid c' cs cs' ?_)
    simpa [Nat.add_assoc, Nat.add_comm] using hp

theorem set_of_valid (cs cs' : List Char) (c' : Char) :
    set ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ c' = ⟨cs ++ cs'.modifyHead fun _ => c'⟩ :=
  congrArg String.mk (utf8SetAux_of_valid _ _ _ (Nat.zero_add _))

theorem modify_of_valid (cs cs' : List Char) :
    modify ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ f = ⟨cs ++ cs'.modifyHead f⟩ := by
  rw [modify, set_of_valid, get_of_valid]; cases cs' <;> rfl

theorem next_of_valid' (cs cs' : List Char) :
    next ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ = ⟨utf8Len cs + csize (cs'.headD default)⟩ := by
  simp only [next, get_of_valid]; rfl

theorem next_of_valid (cs : List Char) (c : Char) (cs' : List Char) :
    next ⟨cs ++ c :: cs'⟩ ⟨utf8Len cs⟩ = ⟨utf8Len cs + csize c⟩ := next_of_valid' ..

theorem lt_next' (s : String) (p : Pos) : p < next s p := lt_next ..

@[simp] theorem atEnd_iff (s : String) (p : Pos) : atEnd s p ↔ s.endPos ≤ p :=
  decide_eq_true_iff _

theorem valid_next {p : Pos} (h : p.Valid s) (h₂ : p < s.endPos) : (next s p).Valid s := by
  match s, p, h with
  | ⟨_⟩, ⟨_⟩, ⟨cs, [], rfl, rfl⟩ => simp at h₂
  | ⟨_⟩, ⟨_⟩, ⟨cs, c::cs', rfl, rfl⟩ =>
    rw [utf8ByteSize.go_eq, next_of_valid]
    simpa using Pos.Valid.mk (cs ++ [c]) cs'

theorem utf8PrevAux_of_valid {cs cs' : List Char} {c : Char} {i p : Nat}
    (hp : i + (utf8Len cs + csize c) = p) :
    utf8PrevAux (cs ++ c :: cs') ⟨i⟩ ⟨p⟩ = ⟨i + utf8Len cs⟩ := by
  match cs with
  | [] => simp [utf8PrevAux, ← hp, Pos.addChar_eq]
  | c'::cs =>
    simp [← hp, utf8PrevAux, Pos.addChar_eq]; rw [if_neg]
    case hnc => rw [Pos.ext_iff, Nat.add_right_comm, Nat.add_left_comm]; apply ne_add_csize_add_self
    refine (utf8PrevAux_of_valid (by simp [Nat.add_assoc, Nat.add_left_comm])).trans ?_
    simp [Nat.add_assoc, Nat.add_comm]

theorem prev_of_valid (cs : List Char) (c : Char) (cs' : List Char) :
    prev ⟨cs ++ c :: cs'⟩ ⟨utf8Len cs + csize c⟩ = ⟨utf8Len cs⟩ := by
  simp [prev]; refine (if_neg (Pos.ne_of_gt add_csize_pos)).trans ?_
  rw [utf8PrevAux_of_valid] <;> simp

theorem prev_of_valid' (cs cs' : List Char) :
    prev ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ = ⟨utf8Len cs.dropLast⟩ := by
  match cs, cs.eq_nil_or_concat with
  | _, .inl rfl => rfl
  | _, .inr ⟨cs, c, rfl⟩ => simp [prev_of_valid]

@[simp] theorem prev_zero (s : String) : prev s 0 = 0 := rfl

theorem front_eq (s : String) : front s = s.1.headD default := by
  simpa [front] using get_of_valid [] s.1

theorem back_eq (s : String) : back s = s.1.getLastD default := by
  match s, s.1.eq_nil_or_concat with
  | ⟨_⟩, .inl rfl => rfl
  | ⟨_⟩, .inr ⟨cs, c, rfl⟩ => simp [back, prev_of_valid, get_of_valid]

theorem atEnd_of_valid (cs : List Char) (cs' : List Char) :
    atEnd ⟨cs ++ cs'⟩ ⟨utf8Len cs⟩ ↔ cs' = [] := by
  simp [atEnd_iff]
  cases cs' <;> simp [Pos.le_iff, Nat.lt_add_of_pos_right add_csize_pos]

@[simp] theorem get'_eq (s : String) (p : Pos) (h) : get' s p h = get s p := rfl

@[simp] theorem next'_eq (s : String) (p : Pos) (h) : next' s p h = next s p := rfl

theorem extract.go₂_add_right_cancel (s : List Char) (i e n : Nat) :
    go₂ s ⟨i + n⟩ ⟨e + n⟩ = go₂ s ⟨i⟩ ⟨e⟩ := by
  apply utf8InductionOn s ⟨i⟩ ⟨e⟩ (motive := fun s i =>
    go₂ s ⟨i.byteIdx + n⟩ ⟨e + n⟩ = go₂ s i ⟨e⟩) <;> simp [go₂]
  intro c cs ⟨i⟩ h ih
  simp [Pos.ext_iff, Pos.addChar_eq] at h ⊢
  simp [Nat.add_right_cancel_iff, h]
  rw [Nat.add_right_comm]
  exact ih

theorem extract.go₂_append_left : ∀ (s t : List Char) (i e : Nat),
    e = utf8Len s + i → go₂ (s ++ t) ⟨i⟩ ⟨e⟩ = s
| [], t, i, _, rfl => by cases t <;> simp [go₂]
| c :: cs, t, i, _, rfl => by
  simp [go₂, Pos.ext_iff, ne_add_csize_add_self, Pos.addChar_eq]
  apply go₂_append_left; rw [Nat.add_right_comm, Nat.add_assoc]

theorem extract.go₁_add_right_cancel (s : List Char) (i b e n : Nat) :
    go₁ s ⟨i + n⟩ ⟨b + n⟩ ⟨e + n⟩ = go₁ s ⟨i⟩ ⟨b⟩ ⟨e⟩ := by
  apply utf8InductionOn s ⟨i⟩ ⟨b⟩ (motive := fun s i =>
    go₁ s ⟨i.byteIdx + n⟩ ⟨b + n⟩ ⟨e + n⟩ = go₁ s i ⟨b⟩ ⟨e⟩) <;>
  simp [go₁]
  · intro c cs
    apply go₂_add_right_cancel
  · intro c cs ⟨i⟩ h ih
    simp [Pos.ext_iff, Pos.addChar_eq] at h ih ⊢
    simp [Nat.add_right_cancel_iff, h]
    rw [Nat.add_right_comm]
    exact ih

theorem extract.go₁_cons_addChar (c : Char) (cs : List Char) (b e : Pos) :
    go₁ (c :: cs) 0 (b + c) (e + c) = go₁ cs 0 b e := by
  simp [go₁, Pos.ext_iff, Nat.ne_of_lt add_csize_pos]
  apply go₁_add_right_cancel

theorem extract.go₁_append_right : ∀ (s t : List Char) (i b : Nat) (e : Pos),
    b = utf8Len s + i → go₁ (s ++ t) ⟨i⟩ ⟨b⟩ e = go₂ t ⟨b⟩ e
| [], t, i, _, e, rfl => by cases t <;> simp [go₁, go₂]
| c :: cs, t, i, _, e, rfl => by
  simp [go₁, Pos.ext_iff, ne_add_csize_add_self, Pos.addChar_eq]
  apply go₁_append_right; rw [Nat.add_right_comm, Nat.add_assoc]

theorem extract.go₁_zero_utf8Len (s : List Char) : go₁ s 0 0 ⟨utf8Len s⟩ = s :=
  (go₁_append_right [] s 0 0 ⟨utf8Len s⟩ rfl).trans <| by
    simpa using go₂_append_left s [] 0 (utf8Len s) rfl

theorem extract_cons_addChar (c : Char) (cs : List Char) (b e : Pos) :
    extract ⟨c :: cs⟩ (b + c) (e + c) = extract ⟨cs⟩ b e := by
  simp [extract, Nat.add_le_add_iff_le_right]
  split <;> [rfl, rw [extract.go₁_cons_addChar]]

theorem extract_zero_endPos : ∀ (s : String), s.extract 0 (endPos s) = s
| ⟨[]⟩ => rfl
| ⟨c :: cs⟩ => by
  simp [extract, Nat.ne_of_gt add_csize_pos]; congr
  apply extract.go₁_zero_utf8Len

theorem extract_of_valid (l m r : List Char) :
    extract ⟨l ++ m ++ r⟩ ⟨utf8Len l⟩ ⟨utf8Len l + utf8Len m⟩ = ⟨m⟩ := by
  simp only [extract]
  split
  · next h => rw [utf8Len_eq_zero.1 <| Nat.le_zero.1 <| (Nat.add_le_add_iff_le_left _ _ 0).1 h]
  · congr; rw [List.append_assoc, extract.go₁_append_right _ _ _ _ _ (by rfl)]
    apply extract.go₂_append_left; apply Nat.add_comm

theorem Iterator.hasNext_cons_addChar (c : Char) (cs : List Char) (i : Pos) :
    hasNext ⟨⟨c :: cs⟩, i + c⟩ = hasNext ⟨⟨cs⟩, i⟩ := by
  simp [hasNext, Nat.add_lt_add_iff_lt_right]

@[simp] theorem toString_toSubstring (s : String) : s.toSubstring.toString = s :=
  extract_zero_endPos _

attribute [simp] toSubstring'

theorem join_eq (ss : List String) : join ss = ⟨(ss.map data).join⟩ := go ss [] where
  go : ∀ (ss : List String) cs, ss.foldl (· ++ ·) (mk cs) = ⟨cs ++ (ss.map data).join⟩
    | [], _ => by simp
    | ⟨s⟩::ss, _ => (go ss _).trans (by simp)

@[simp] theorem data_join (ss : List String) : (join ss).data = (ss.map data).join := by
  rw [join_eq]

theorem singleton_eq (c : Char) : singleton c = ⟨[c]⟩ := rfl

@[simp] theorem data_singleton (c : Char) : (singleton c).data = [c] := rfl

@[simp] theorem append_nil (s : String) : s ++ "" = s := congrArg mk (List.append_nil _)

@[simp] theorem nil_append (s : String) : "" ++ s = s := rfl

theorem append_assoc (s₁ s₂ s₃ : String) : (s₁ ++ s₂) ++ s₃ = s₁ ++ (s₂ ++ s₃) :=
  congrArg mk (List.append_assoc ..)

namespace Iterator

@[simp] theorem forward_eq_nextn : forward = nextn := by
  funext it n; induction n generalizing it <;> simp [forward, nextn, *]

/-- Validity for a string iterator. -/
def Valid (it : Iterator) : Prop := it.pos.Valid it.s

/-- `it.ValidFor l r` means that `it` is a string iterator whose underlying string is
`l.reverse ++ r`, and where the cursor is pointing at the end of `l.reverse`. -/
inductive ValidFor (l r : List Char) : Iterator → Prop
  /-- The canonical constructor for `ValidFor`. -/
  | mk : ValidFor l r ⟨⟨l.reverseAux r⟩, ⟨utf8Len l⟩⟩

attribute [simp] toString pos

namespace ValidFor

theorem valid : ∀ {it}, ValidFor l r it → Valid it
  | _, ⟨⟩ => by simpa [List.reverseAux_eq] using Pos.Valid.mk l.reverse r

theorem out : ∀ {it}, ValidFor l r it → it = ⟨⟨l.reverseAux r⟩, ⟨utf8Len l⟩⟩
  | _, ⟨⟩ => rfl

theorem out' : ∀ {it}, ValidFor l r it → it = ⟨⟨l.reverse ++ r⟩, ⟨utf8Len l.reverse⟩⟩
  | _, ⟨⟩ => by simp [List.reverseAux_eq]

theorem mk' : ValidFor l r ⟨⟨l.reverse ++ r⟩, ⟨utf8Len l.reverse⟩⟩ := by
  simpa [List.reverseAux_eq] using mk

theorem of_eq : ∀ it, it.1.1 = l.reverseAux r → it.2.1 = utf8Len l → ValidFor l r it
  | ⟨⟨_⟩, ⟨_⟩⟩, rfl, rfl => ⟨⟩

theorem _root_.String.validFor_mkIterator (s) : (mkIterator s).ValidFor [] s.1 := ⟨⟩

theorem remainingBytes : ∀ {it}, ValidFor l r it → it.remainingBytes = utf8Len r
  | _, ⟨⟩ => by simp [Iterator.remainingBytes, Nat.add_sub_cancel_left]

theorem toString : ∀ {it}, ValidFor l r it → it.1 = ⟨l.reverseAux r⟩
  | _, ⟨⟩ => rfl

theorem pos : ∀ {it}, ValidFor l r it → it.2 = ⟨utf8Len l⟩
  | _, ⟨⟩ => rfl

theorem pos_eq_zero {l r it} (h : ValidFor l r it) : it.2 = 0 ↔ l = [] := by
  simp [h.pos, Pos.ext_iff]

theorem pos_eq_endPos {l r it} (h : ValidFor l r it) : it.2 = it.1.endPos ↔ r = [] := by
  simp [h.pos, h.toString, Pos.ext_iff]
  exact (Nat.add_left_cancel_iff (m := 0)).trans <| eq_comm.trans utf8Len_eq_zero

theorem curr : ∀ {it}, ValidFor l r it → it.curr = r.headD default
  | it, h => by cases h.out'; apply get_of_valid

theorem next : ∀ {it}, ValidFor l (c :: r) it → ValidFor (c :: l) r it.next
  | it, h => by
    cases h.out'
    simp only [Iterator.next, next_of_valid l.reverse c r]
    rw [← List.reverseAux_eq, utf8Len_reverse]; constructor

theorem prev : ∀ {it}, ValidFor (c :: l) r it → ValidFor l (c :: r) it.prev
  | it, h => by
    cases h.out'
    have := prev_of_valid l.reverse c r
    simp at this; simp [Iterator.prev, this]
    exact .of_eq _ (by simp [List.reverseAux_eq]) (by simp)

theorem prev_nil : ∀ {it}, ValidFor [] r it → ValidFor [] r it.prev
  | it, h => by simp [Iterator.prev, h.toString, h.pos]; constructor

theorem atEnd : ∀ {it}, ValidFor l r it → (it.atEnd ↔ r = [])
  | it, h => by
    simp [Iterator.atEnd, h.pos, h.toString]
    exact (Nat.add_le_add_iff_le_left _ _ 0).trans <| Nat.le_zero.trans utf8Len_eq_zero

theorem hasNext : ∀ {it}, ValidFor l r it → (it.hasNext ↔ r ≠ [])
  | it, h => by simp [Iterator.hasNext, ← h.atEnd, Iterator.atEnd]

theorem hasPrev : ∀ {it}, ValidFor l r it → (it.hasPrev ↔ l ≠ [])
  | it, h => by simp [Iterator.hasPrev, h.pos, Nat.pos_iff_ne_zero]

theorem setCurr' : ∀ {it}, ValidFor l r it →
    ValidFor l (r.modifyHead fun _ => c) (it.setCurr c)
  | it, h => by
    cases h.out'
    simp [Iterator.setCurr]
    refine .of_eq _ ?_ (by simp)
    have := set_of_valid l.reverse r c
    simp at this; simp [List.reverseAux_eq, this]

theorem setCurr (h : ValidFor l (c :: r) it) :
    ValidFor l (c :: r) (it.setCurr c) := h.setCurr'

theorem toEnd (h : ValidFor l r it) : ValidFor (r.reverse ++ l) [] it.toEnd := by
  simp [Iterator.toEnd, h.toString]
  exact .of_eq _ (by simp [List.reverseAux_eq]) (by simp [Nat.add_comm])

theorem toEnd' (it : Iterator) : ValidFor it.s.1.reverse [] it.toEnd := by
  simp [Iterator.toEnd]
  exact .of_eq _ (by simp [List.reverseAux_eq]) (by simp [endPos, utf8ByteSize])

theorem extract (h₁ : ValidFor l (m ++ r) it₁) (h₂ : ValidFor (m.reverse ++ l) r it₂) :
    it₁.extract it₂ = ⟨m⟩ := by
  cases h₁.out; cases h₂.out
  simp [Iterator.extract, List.reverseAux_eq, Nat.not_lt.2 (Nat.le_add_left ..)]
  simpa [Nat.add_comm] using extract_of_valid l.reverse m r

theorem remainingToString {it} (h : ValidFor l r it) : it.remainingToString = ⟨r⟩ := by
  cases h.out
  simpa [Iterator.remainingToString, List.reverseAux_eq] using extract_of_valid l.reverse r []

theorem nextn : ∀ {it}, ValidFor l r it →
      ∀ n, n ≤ r.length → ValidFor ((r.take n).reverse ++ l) (r.drop n) (it.nextn n)
  | it, h, 0, _ => by simp [h, Iterator.nextn]
  | it, h, n+1, hn => by
    simp [h, Iterator.nextn]
    have a::r := r
    simpa using h.next.nextn _ (Nat.le_of_succ_le_succ hn)

theorem prevn : ∀ {it}, ValidFor l r it →
      ∀ n, n ≤ l.length → ValidFor (l.drop n) ((l.take n).reverse ++ r) (it.prevn n)
  | it, h, 0, _ => by simp [h, Iterator.prevn]
  | it, h, n+1, hn => by
    simp [h, Iterator.prevn]
    have a::l := l
    simpa using h.prev.prevn _ (Nat.le_of_succ_le_succ hn)

end ValidFor

namespace Valid

theorem validFor : ∀ {it}, Valid it → ∃ l r, ValidFor l r it
  | ⟨⟨_⟩, ⟨_⟩⟩, ⟨l, r, rfl, rfl⟩ =>
    ⟨l.reverse, r, by simpa [List.reverseAux_eq] using @ValidFor.mk l.reverse r⟩

theorem _root_.String.valid_mkIterator (s) : (mkIterator s).Valid := s.validFor_mkIterator.valid

theorem remainingBytes_le : ∀ {it}, Valid it → it.remainingBytes ≤ utf8ByteSize it.s
  | _, h => let ⟨l, r, h⟩ := h.validFor; by simp [h.remainingBytes, h.toString, Nat.le_add_left]

theorem next : ∀ {it}, Valid it → it.hasNext → Valid it.next
  | _, h, hn => by
    let ⟨l, r, h⟩ := h.validFor
    obtain ⟨c, r, rfl⟩ := List.exists_cons_of_ne_nil (h.hasNext.1 hn)
    exact h.next.valid

theorem prev : ∀ {it}, Valid it → Valid it.prev
  | _, h =>
    match h.validFor with
    | ⟨[], _, h⟩ => h.prev_nil.valid
    | ⟨_::_, _, h⟩ => h.prev.valid

theorem setCurr : ∀ {it}, Valid it → Valid (it.setCurr c)
  | it, h => by
    let ⟨l, r, h⟩ := h.validFor
    exact h.setCurr'.valid

theorem toEnd (it : String.Iterator) : Valid it.toEnd := (ValidFor.toEnd' _).valid

theorem remainingToString {it} (h : ValidFor l r it) : it.remainingToString = ⟨r⟩ := by
  cases h.out
  simpa [Iterator.remainingToString, List.reverseAux_eq] using extract_of_valid l.reverse r []

theorem prevn (h : Valid it) : ∀ n, Valid (it.prevn n)
  | 0 => h
  | n+1 => h.prev.prevn n

end Valid
end Iterator
end String

open String

namespace Substring

@[simp] theorem prev_zero (s : Substring) : s.prev 0 = 0 := by simp [prev, Pos.add_eq]

@[simp] theorem prevn_zero (s : Substring) : ∀ n, s.prevn n 0 = 0
  | 0 => rfl
  | n+1 => by simp [prevn, prevn_zero s n]

/-- Validity for a substring. -/
structure Valid (s : Substring) : Prop where
  /-- The start position of a valid substring is valid. -/
  startValid : s.startPos.Valid s.str
  /-- The stop position of a valid substring is valid. -/
  stopValid : s.stopPos.Valid s.str
  /-- The stop position of a substring is at least the start. -/
  le : s.startPos ≤ s.stopPos

theorem Valid_default : Valid default := ⟨Pos.valid_zero, Pos.valid_zero, Nat.le_refl _⟩

/-- A substring is represented by three lists `l m r`, where `m` is the middle section
(the actual substring) and `l ++ m ++ r` is the underlying string. -/
inductive ValidFor (l m r : List Char) : Substring → Prop
  /-- The constructor for `ValidFor`. -/
  | mk : ValidFor l m r ⟨⟨l ++ m ++ r⟩, ⟨utf8Len l⟩, ⟨utf8Len l + utf8Len m⟩⟩

namespace ValidFor

theorem valid : ∀ {s}, ValidFor l m r s → Valid s
  | _, ⟨⟩ => ⟨⟨l, m ++ r, by simp⟩, ⟨l ++ m, r, by simp⟩, Nat.le_add_right ..⟩

theorem of_eq : ∀ s,
    s.str.1 = l ++ m ++ r →
    s.startPos.1 = utf8Len l →
    s.stopPos.1 = utf8Len l + utf8Len m →
    ValidFor l m r s
  | ⟨⟨_⟩, ⟨_⟩, ⟨_⟩⟩, rfl, rfl, rfl => ⟨⟩

theorem _root_.String.validFor_toSubstring (s : String) : ValidFor [] s.1 [] s.toSubstring :=
  .of_eq _ (by simp [toSubstring]) rfl (by simp [toSubstring, endPos, utf8ByteSize])

theorem str : ∀ {s}, ValidFor l m r s → s.str = ⟨l ++ m ++ r⟩
  | _, ⟨⟩ => rfl

theorem startPos : ∀ {s}, ValidFor l m r s → s.startPos = ⟨utf8Len l⟩
  | _, ⟨⟩ => rfl

theorem stopPos : ∀ {s}, ValidFor l m r s → s.stopPos = ⟨utf8Len l + utf8Len m⟩
  | _, ⟨⟩ => rfl

theorem bsize : ∀ {s}, ValidFor l m r s → s.bsize = utf8Len m
  | _, ⟨⟩ => by simp [Substring.bsize, Nat.add_sub_cancel_left]

theorem isEmpty : ∀ {s}, ValidFor l m r s → (s.isEmpty ↔ m = [])
  | _, h => by simp [Substring.isEmpty, h.bsize]

theorem toString : ∀ {s}, ValidFor l m r s → s.toString = ⟨m⟩
  | _, ⟨⟩ => by simpa [Substring.toString] using extract_of_valid l m r

theorem toIterator : ∀ {s}, ValidFor l m r s → s.toIterator.ValidFor l.reverse (m ++ r)
  | _, h => by
    simp [Substring.toIterator]
    exact .of_eq _ (by simp [h.str, List.reverseAux_eq]) (by simp [h.startPos])

theorem get : ∀ {s}, ValidFor l (m₁ ++ c :: m₂) r s → s.get ⟨utf8Len m₁⟩ = c
  | _, ⟨⟩ => by simpa using get_of_valid (l ++ m₁) (c :: m₂ ++ r)

theorem next : ∀ {s}, ValidFor l (m₁ ++ c :: m₂) r s → s.next ⟨utf8Len m₁⟩ = ⟨utf8Len m₁ + csize c⟩
  | _, ⟨⟩ => by
    simp [Substring.next]
    rw [if_neg (mt Pos.ext_iff.1 ?a)]
    case a =>
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using
        @ne_add_csize_add_self (utf8Len l + utf8Len m₁) (utf8Len m₂) c
    have := next_of_valid (l ++ m₁) c (m₂ ++ r)
    simp [Pos.add_eq] at this ⊢; rw [this]
    simp [Nat.add_assoc, Nat.add_sub_cancel_left]

theorem next_stop : ∀ {s}, ValidFor l m r s → s.next ⟨utf8Len m⟩ = ⟨utf8Len m⟩
  | _, ⟨⟩ => by simp [Substring.next, Pos.add_eq]

theorem prev : ∀ {s}, ValidFor l (m₁ ++ c :: m₂) r s → s.prev ⟨utf8Len m₁ + csize c⟩ = ⟨utf8Len m₁⟩
  | _, ⟨⟩ => by
    simp [Substring.prev]
    rw [if_neg (mt Pos.ext_iff.1 <| Ne.symm ?a)]
    case a => simpa [Nat.add_comm] using @ne_add_csize_add_self (utf8Len l) (utf8Len m₁) c
    have := prev_of_valid (l ++ m₁) c (m₂ ++ r)
    simp [Pos.add_eq, Nat.add_assoc] at this ⊢; rw [this]
    simp [Nat.add_sub_cancel_left]

theorem nextn_stop : ∀ {s}, ValidFor l m r s → ∀ n, s.nextn n ⟨utf8Len m⟩ = ⟨utf8Len m⟩
  | _, _, 0 => rfl
  | _, h, n+1 => by simp [Substring.nextn, h.next_stop, h.nextn_stop n]

theorem nextn : ∀ {s}, ValidFor l (m₁ ++ m₂) r s →
    ∀ n, s.nextn n ⟨utf8Len m₁⟩ = ⟨utf8Len m₁ + utf8Len (m₂.take n)⟩
  | _, _, 0 => by simp [Substring.nextn]
  | s, h, n+1 => by
    simp [Substring.nextn]
    match m₂ with
    | [] => simp at h; simp [h.next_stop, h.nextn_stop]
    | c::m₂ =>
      rw [h.next]
      have := @nextn l (m₁ ++ [c]) m₂ r s (by simp [h]) n
      simp at this; rw [this]; simp [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm]

theorem prevn : ∀ {s}, ValidFor l (m₁.reverse ++ m₂) r s →
    ∀ n, s.prevn n ⟨utf8Len m₁⟩ = ⟨utf8Len (m₁.drop n)⟩
  | _, _, 0 => by simp [Substring.prevn]
  | s, h, n+1 => by
    simp [Substring.prevn]
    match m₁ with
    | [] => simp
    | c::m₁ =>
      rw [List.reverse_cons, List.append_assoc] at h
      have := h.prev; simp at this; simp [this, h.prevn n]

theorem front : ∀ {s}, ValidFor l (c :: m) r s → s.front = c
  | _, h => h.get (m₁ := [])

theorem drop : ∀ {s}, ValidFor l m r s → ∀ n, ValidFor (l ++ m.take n) (m.drop n) r (s.drop n)
  | s, h, n => by
    have : Substring.nextn {..} .. = _ := h.nextn (m₁ := []) n
    simp at this; simp [Substring.drop, this]
    simp [h.str, h.startPos, h.stopPos]
    rw [← List.take_append_drop n m] at h
    refine .of_eq _ (by simp) (by simp) ?_
    conv => lhs; rw [← List.take_append_drop n m]
    simp [-List.take_append_drop, Nat.add_assoc]

theorem take : ∀ {s}, ValidFor l m r s → ∀ n, ValidFor l (m.take n) (m.drop n ++ r) (s.take n)
  | s, h, n => by
    have : Substring.nextn {..} .. = _ := h.nextn (m₁ := []) n
    simp at this; simp [Substring.take, this]
    simp [h.str, h.startPos, h.stopPos]
    rw [← List.take_append_drop n m] at h
    refine .of_eq _ ?_ (by simp) (by simp)
    conv => lhs; rw [← List.take_append_drop n m]
    simp [-List.take_append_drop, Nat.add_assoc]

-- TODO: takeRight, dropRight

theorem atEnd : ∀ {s}, ValidFor l m r s → (s.atEnd ⟨p⟩ ↔ p = utf8Len m)
  | _, ⟨⟩ => by simp [Substring.atEnd, Pos.ext_iff, Nat.add_left_cancel_iff]

theorem extract : ∀ {s}, ValidFor l m r s → ValidFor ml mm mr ⟨⟨m⟩, b, e⟩ →
    ∃ l' r', ValidFor l' mm r' (s.extract b e)
  | _, ⟨⟩, ⟨⟩ => by
    simp [Substring.extract]; split
    · next h =>
      rw [utf8Len_eq_zero.1 <| Nat.le_zero.1 <| (Nat.add_le_add_iff_le_left _ _ 0).1 h]
      exact ⟨[], [], ⟨⟩⟩
    · next h =>
      refine ⟨l ++ ml, mr ++ r, .of_eq _ (by simp) ?_ ?_⟩ <;>
        simp [Nat.min_eq_min] <;> rw [Nat.min_eq_right] <;>
        simp [Nat.add_le_add_iff_le_left, Nat.le_add_right]
      rw [Nat.add_assoc]

end ValidFor

namespace Valid

theorem validFor : ∀ {s}, Valid s → ∃ l m r, ValidFor l m r s
  | ⟨⟨_⟩, ⟨_⟩, ⟨_⟩⟩, ⟨⟨l, mr, rfl, rfl⟩, ⟨lm, r, e, rfl⟩, h⟩ => by
    simp at *
    have := (or_iff_right_iff_imp.2 fun h => ?x).1 (List.append_eq_append_iff.1 e)
    case x =>
      match l, r, h with | _, _, ⟨m, rfl, rfl⟩ => ?_
      simp at h
      cases utf8Len_eq_zero.1 <| Nat.le_zero.1 (Nat.le_of_add_le_add_left (c := 0) h)
      exact ⟨[], by simp⟩
    match lm, mr, this with
    | _, _, ⟨m, rfl, rfl⟩ => exact ⟨l, m, r, by simpa using ValidFor.mk⟩

theorem valid : ∀ {s}, ValidFor l m r s → Valid s
  | _, ⟨⟩ => ⟨⟨l, m ++ r, by simp⟩, ⟨l ++ m, r, by simp⟩, Nat.le_add_right ..⟩

theorem _root_.String.valid_toSubstring (s : String) : s.toSubstring.Valid :=
  s.validFor_toSubstring.valid

theorem bsize : ∀ {s}, Valid s → s.bsize = utf8Len s.toString.1
  | _, h => let ⟨l, m, r, h⟩ := h.validFor; by simp [h.bsize, h.toString]

theorem isEmpty : ∀ {s}, Valid s → (s.isEmpty ↔ s.toString = "")
  | _, h => let ⟨l, m, r, h⟩ := h.validFor; by simp [h.isEmpty, h.toString, ext_iff]

theorem get : ∀ {s}, Valid s → s.toString.1 = m₁ ++ c :: m₂ → s.get ⟨utf8Len m₁⟩ = c
  | _, h, e => by
    let ⟨l, m, r, h⟩ := h.validFor
    simp [h.toString] at e; subst e; simp [h.get]

theorem next : ∀ {s}, Valid s → s.toString.1 = m₁ ++ c :: m₂ →
    s.next ⟨utf8Len m₁⟩ = ⟨utf8Len m₁ + csize c⟩
  | _, h, e => by
    let ⟨l, m, r, h⟩ := h.validFor
    simp [h.toString] at e; subst e; simp [h.next]

theorem next_stop : ∀ {s}, Valid s → s.next ⟨s.bsize⟩ = ⟨s.bsize⟩
  | _, h => let ⟨l, m, r, h⟩ := h.validFor; by simp [h.bsize, h.next_stop]

theorem prev : ∀ {s}, Valid s → s.toString.1 = m₁ ++ c :: m₂ →
    s.prev ⟨utf8Len m₁ + csize c⟩ = ⟨utf8Len m₁⟩
  | _, h, e => by
    let ⟨l, m, r, h⟩ := h.validFor
    simp [h.toString] at e; subst e; simp [h.prev]

theorem nextn_stop : ∀ {s}, Valid s → ∀ n, s.nextn n ⟨s.bsize⟩ = ⟨s.bsize⟩
  | _, h, n => let ⟨l, m, r, h⟩ := h.validFor; by simp [h.bsize, h.nextn_stop]

theorem nextn : ∀ {s}, Valid s → s.toString.1 = m₁ ++ m₂ →
    ∀ n, s.nextn n ⟨utf8Len m₁⟩ = ⟨utf8Len m₁ + utf8Len (m₂.take n)⟩
  | _, h, e => by
    let ⟨l, m, r, h⟩ := h.validFor
    simp [h.toString] at e; subst e; simp [h.nextn]

theorem prevn : ∀ {s}, Valid s → s.toString.1 = m₁.reverse ++ m₂ →
    ∀ n, s.prevn n ⟨utf8Len m₁⟩ = ⟨utf8Len (m₁.drop n)⟩
  | _, h, e => by
    let ⟨l, m, r, h⟩ := h.validFor
    simp [h.toString] at e; subst e; simp [h.prevn]

theorem front : ∀ {s}, Valid s → s.toString.1 = c :: m → s.front = c
  | _, h => h.get (m₁ := [])

theorem drop : ∀ {s}, Valid s → ∀ n, Valid (s.drop n)
  | _, h, _ => let ⟨_, _, _, h⟩ := h.validFor; (h.drop _).valid

theorem data_drop : ∀ {s}, Valid s → ∀ n, (s.drop n).toString.1 = s.toString.1.drop n
  | _, h, _ => let ⟨_, _, _, h⟩ := h.validFor; by simp [(h.drop _).toString, h.toString]

theorem take : ∀ {s}, Valid s → ∀ n, Valid (s.take n)
  | _, h, _ => let ⟨_, _, _, h⟩ := h.validFor; (h.take _).valid

theorem data_take : ∀ {s}, Valid s → ∀ n, (s.take n).toString.1 = s.toString.1.take n
  | _, h, _ => let ⟨_, _, _, h⟩ := h.validFor; by simp [(h.take _).toString, h.toString]

-- TODO: takeRight, dropRight

theorem atEnd : ∀ {s}, Valid s → (s.atEnd ⟨p⟩ ↔ p = utf8ByteSize s.toString)
  | _, h => let ⟨_, _, _, h⟩ := h.validFor; by simp [h.atEnd, h.toString]

theorem extract : ∀ {s}, Valid s → Valid ⟨s.toString, b, e⟩ → Valid (s.extract b e)
  | _, h₁, h₂ => by
    let ⟨l, m, r, h₁⟩ := h₁.validFor
    rw [h₁.toString] at h₂
    let ⟨ml, mm, mr, h₂⟩ := h₂.validFor
    have ⟨l', r', h₃⟩ := h₁.extract h₂
    exact h₃.valid

theorem toString_extract : ∀ {s}, Valid s → Valid ⟨s.toString, b, e⟩ →
    (s.extract b e).toString = s.toString.extract b e
  | _, h₁, h₂ => by
    let ⟨l, m, r, h₁⟩ := h₁.validFor
    rw [h₁.toString] at h₂
    let ⟨ml, mm, mr, h₂⟩ := h₂.validFor
    have ⟨l', r', h₃⟩ := h₁.extract h₂
    rw [h₃.toString, h₁.toString, ← h₂.toString, toString]

end Valid
end Substring

namespace String

theorem drop_eq (s : String) (n : Nat) : s.drop n = ⟨s.1.drop n⟩ :=
  (s.validFor_toSubstring.drop n).toString

@[simp] theorem data_drop (s : String) (n : Nat) : (s.drop n).1 = s.1.drop n := by rw [drop_eq]

@[simp] theorem drop_empty {n : Nat} : "".drop n = "" := by rw [drop_eq, List.drop_nil]

theorem take_eq (s : String) (n : Nat) : s.take n = ⟨s.1.take n⟩ :=
  (s.validFor_toSubstring.take n).toString

@[simp] theorem data_take (s : String) (n : Nat) : (s.take n).1 = s.1.take n := by rw [take_eq]

end String