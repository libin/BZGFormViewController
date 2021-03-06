//
//  BZGFormFieldCell.m
//
//  https://github.com/benzguo/BZGFormViewController
//

#import "BZGFormFieldCell.h"
#import "ReactiveCocoa.h"
#import "EXTScope.h"

@implementation BZGFormFieldCell

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.imageView.hidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        CGFloat activityIndicatorWidth = self.bounds.size.height*0.7;
        CGRect activityIndicatorFrame = CGRectMake(self.bounds.size.width - activityIndicatorWidth,
                                                   0,
                                                   activityIndicatorWidth,
                                                   self.bounds.size.height);
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicatorView setFrame:activityIndicatorFrame];
        self.activityIndicatorView.hidesWhenStopped = NO;
        self.activityIndicatorView.hidden = YES;
        [self addSubview:self.activityIndicatorView];

        CGFloat textFieldX = self.bounds.size.width * 0.35;
        CGFloat labelX = 10;
        CGRect labelFrame = CGRectMake(labelX,
                                       0,
                                       textFieldX - labelX,
                                       self.bounds.size.height);
        self.label = [[UILabel alloc] initWithFrame:labelFrame];
        self.label.font = [UIFont boldSystemFontOfSize:self.label.font.pointSize];
        [self addSubview:self.label];

        CGRect textFieldFrame = CGRectMake(textFieldX,
                                           0,
                                           self.bounds.size.width - textFieldX - activityIndicatorWidth,
                                           self.bounds.size.height);
        self.textField = [[UITextField alloc] initWithFrame:textFieldFrame];
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.textColor = [UIColor blackColor];
        [self addSubview:self.textField];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldTextDidEndEditing:)
                                                     name:UITextFieldTextDidEndEditingNotification object:nil];

        self.validationState = BZGValidationStateNone;
        self.infoText = @"";

        @weakify(self);
        RAC(self.textField, textColor) =
        [RACObserve(self, validationState) map:^UIColor *(NSNumber *validationState) {
            @strongify(self);
            if (self.textField.editing || self.textField.isFirstResponder) {
                return [UIColor blackColor];
            }
            switch (validationState.integerValue) {
                case BZGValidationStateInvalid:
                    return [UIColor redColor];
                    break;
                case BZGValidationStateValid:
                case BZGValidationStateValidating:
                case BZGValidationStateWarning:
                case BZGValidationStateNone:
                default:
                    return [UIColor blackColor];
                    break;
            }
        }];

        RAC(self, accessoryType) =
        [RACObserve(self, validationState) map:^NSNumber *(NSNumber *validationState) {
            @strongify(self);
            if (validationState.integerValue == BZGValidationStateValid
                && !self.textField.editing) {
                return @(UITableViewCellAccessoryCheckmark);
            } else {
                return @(UITableViewCellAccessoryNone);
            }
        }];

        RAC(self.activityIndicatorView, hidden) =
        [RACObserve(self, validationState) map:^NSNumber *(NSNumber *validationState) {
            @strongify(self);
            if (validationState.integerValue == BZGValidationStateValidating) {
                [self.activityIndicatorView startAnimating];
                return @NO;
            } else {
                [self.activityIndicatorView stopAnimating];
                return @YES;
            }
        }];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    return self;
}

+ (BZGFormFieldCell *)parentCellForTextField:(UITextField *)textField
{
    UIView *view = textField;
    while ((view = view.superview)) {
        if ([view isKindOfClass:[BZGFormFieldCell class]]) break;
    }
    return (BZGFormFieldCell *)view;
}


#pragma mark - UITextField notifications

// Flush validation state signal
- (void)textFieldTextDidEndEditing:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if ([textField isEqual:self.textField]) {
        self.validationState = self.validationState;
    }
}


@end
