const operators = {
    binary: {
        '===': (a, b) => (a === b),
        '!==': (a, b) => (a !== b),
        '==': (a, b) => (a == b), // eslint-disable-line
        '!=': (a, b) => (a != b), // eslint-disable-line
        '>': (a, b) => (a > b),
        '<': (a, b) => (a < b),
        '>=': (a, b) => (a >= b),
        '<=': (a, b) => (a <= b),
        '+': (a, b) => (a + b),
        '-': (a, b) => (a - b),
        '*': (a, b) => (a * b),
        '/': (a, b) => (a / b),
        '%': (a, b) => (a % b), // remainder
        '**': (a, b) => (a ** b), // exponentiation
        '&': (a, b) => (a & b), // bitwise AND
        '|': (a, b) => (a | b), // bitwise OR
        '^': (a, b) => (a ^ b), // bitwise XOR
        '<<': (a, b) => (a << b), // left shift
        '>>': (a, b) => (a >> b), // sign-propagating right shift
        '>>>': (a, b) => (a >>> b), // zero-fill right shift
        // Let's make a home for the logical operators here as well
        '||': (a, b) => (a || b),
        '&&': (a, b) => (a && b),
    },
    unary: {
        '!': a => !a,
        '~': a => ~a, // bitwise NOT
        '+': a => +a, // unary plus
        '-': a => -a, // unary negation
        '++': a => ++a, // increment
        '--': a => --a, // decrement
    },
};

const types = {
    // supported
    LITERAL: 'Literal',
    UNARY: 'UnaryExpression',
    BINARY: 'BinaryExpression',
    LOGICAL: 'LogicalExpression',
    CONDITIONAL: 'ConditionalExpression',  // a ? b : c
    MEMBER: 'MemberExpression',
    IDENTIFIER: 'Identifier',
    THIS: 'ThisExpression', // e.g. 'this.willBeUsed'
    CALL: 'CallExpression', // e.g. whatcha(doing)
    ARRAY: 'ArrayExpression', // e.g. [a, 2, g(h), 'etc']
    COMPOUND: 'Compound' // 'a===2, b===3' <-- multiple comma separated expressions.. returns last
};
const undefOperator = () => undefined;

const evaluateExpressionNode = (node, context) => {
    switch (node.type) {
        case types.LITERAL: {
            return node.value;
        }
        case types.THIS: {
            return context;
        }
        case types.COMPOUND: {
            const expressions = node.body.map(el => evaluateExpressionNode(el, context));
            return expressions.pop();
        }
        case types.ARRAY: {
            const elements = node.elements.map(el => evaluateExpressionNode(el, context));
            return elements;
        }
        case types.UNARY: {
            const operator = operators.unary[node.operator] || undefOperator;
            const argument = evaluateExpressionNode(node.argument, context);
            return operator(argument);
        }
        case types.LOGICAL: // !!! fall-through to BINARY !!! //
        case types.BINARY: {
            const operator = operators.binary[node.operator] || undefOperator;
            const left = evaluateExpressionNode(node.left, context);
            const right = evaluateExpressionNode(node.right, context);
            return operator(left, right);
        }
        case types.CONDITIONAL: {
            const test = evaluateExpressionNode(node.test, context);
            const consequent = evaluateExpressionNode(node.consequent, context);
            const alternate = evaluateExpressionNode(node.alternate, context);
            return test ? consequent : alternate;
        }
        case types.CALL : {
            const callee = evaluateExpressionNode(node.callee, context);
            const args = node.arguments.map(arg => evaluateExpressionNode(arg, context));
            return callee(...args);
        }
        case types.IDENTIFIER: {
            return context[node.name];
        }
        case types.MEMBER: {
            const object = evaluateExpressionNode(node.object, context);
            const property = node.computed ? evaluateExpressionNode(node.property, context) : node.property.name;
            const result = object[property];

            if (typeof result == "function") {
                return result.bind(object);
            } else {
                return result;
            }
        }
        default:
            return undefined;
    }
};