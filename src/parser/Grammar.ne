@preprocessor typescript

@{%

import {
  Addition,
  Assignment,
  CompareEqual,
  CompareLessOrEqual,
  Conjunction,
  IfThenElse,
  Multiplication,
  Negation,
  Numeral,
  Sequence,
  Substraction,
  TruthValue,
  Variable,
  WhileDo
} from '../ast/AST';

import { tokens } from './Tokens';
import { MyLexer } from './Lexer';

const lexer = new MyLexer(tokens);

%}

@lexer lexer


# Statements

stmt ->
    identifier "=" aexp ";"               {% ([id, , exp, ]) => (new Assignment(id, exp)) %}
  | "skip" ";"                            {% () => {} %}
  | "{" stmt:* "}"                        {% ([, statements, ]) => (new Sequence(statements)) %}
  | "while" bexp "do" stmt                {% ([, cond, , body]) => (new WhileDo(cond, body)) %}
  | "if" bexp "then" stmt "else" stmt     {% ([, cond, , thenBody, , elseBody]) => (new IfThenElse(cond, thenBody, elseBody)) %}


# Arithmetic expressions

aexp ->
    addsub                  {% id %}

addsub ->
    addsub "+" muldiv       {% ([lhs, , rhs]) => (new Addition(lhs, rhs)) %}
  | addsub "-" muldiv       {% ([lhs, , rhs]) => (new Substraction(lhs, rhs)) %}
  | muldiv                  {% id %}

muldiv ->
    muldiv "*" aexp         {% ([lhs, , rhs]) => (new Multiplication(lhs, rhs)) %}
  | avalue                  {% id %}

avalue ->
    "(" aexp ")"            {% ([, aexp, ]) => (aexp) %}
  | number                  {% ([num]) => (new Numeral(num)) %}
  | identifier              {% ([id]) => (new Variable(id)) %}


# Boolean expressions

bexp ->
    conj                    {% id %}

conj ->
    conj "&&" comp          {% ([lhs, , rhs]) => (new Conjunction(lhs, rhs)) %}
  | comp                    {% id %}

comp ->
    aexp "==" aexp          {% ([lhs, , rhs]) => (new CompareEqual(lhs, rhs)) %}
  | aexp "<=" aexp          {% ([lhs, , rhs]) => (new CompareLessOrEqual(lhs, rhs)) %}
  | neg

neg ->
    "!" bvalue              {% ([, exp]) => (new Negation(exp)) %}
  | bvalue                  {% id %}

bvalue ->
    "(" bexp ")"            {% ([, exp, ]) => (exp) %}
  | "true"                  {% () => (new TruthValue(true)) %}
  | "false"                 {% () => (new TruthValue(false)) %}
  | identifier              {% ([id]) => (new Variable(id)) %}


# Atoms

identifier -> %identifier   {% ([id]) => (id.value) %}
number -> %number           {% ([num]) => (num.value) %}
