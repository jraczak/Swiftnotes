package com.moonpi.swiftnotes;

import android.support.test.espresso.ViewInteraction;
import android.support.test.rule.ActivityTestRule;
import android.support.test.runner.AndroidJUnit4;
import android.test.suitebuilder.annotation.LargeTest;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import com.xamarin.testcloud.espresso.Factory;
import com.xamarin.testcloud.espresso.ReportHelper;

import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;
import org.json.JSONObject;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.UUID;

import static android.support.test.espresso.Espresso.onData;
import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.action.ViewActions.closeSoftKeyboard;
import static android.support.test.espresso.action.ViewActions.replaceText;
import static android.support.test.espresso.action.ViewActions.scrollTo;
import static android.support.test.espresso.assertion.ViewAssertions.doesNotExist;
import static android.support.test.espresso.assertion.ViewAssertions.matches;
import static android.support.test.espresso.matcher.ViewMatchers.hasFocus;
import static android.support.test.espresso.matcher.ViewMatchers.isDisplayed;
import static android.support.test.espresso.matcher.ViewMatchers.withChild;
import static android.support.test.espresso.matcher.ViewMatchers.withContentDescription;
import static android.support.test.espresso.matcher.ViewMatchers.withId;
import static android.support.test.espresso.matcher.ViewMatchers.withParent;
import static android.support.test.espresso.matcher.ViewMatchers.withText;
import static org.hamcrest.CoreMatchers.allOf;
import static org.hamcrest.CoreMatchers.instanceOf;
import static org.hamcrest.CoreMatchers.is;

@LargeTest
@RunWith(AndroidJUnit4.class)
public class testCreateNote {

    @Rule
    public ActivityTestRule<MainActivity> mActivityTestRule = new ActivityTestRule<>(MainActivity.class);

    @Rule
    public ReportHelper reportHelper = Factory.getReportHelper();

    @Test
    public void testCreateNote() {
        ViewInteraction appCompatImageButton = onView(
                allOf(withId(R.id.newNote), withContentDescription("New note"), isDisplayed()));
        appCompatImageButton.perform(click());
        reportHelper.label("NewNote");

        ViewInteraction appCompatEditText = onView(
                allOf(withId(R.id.titleEdit),
                        withParent(allOf(withId(R.id.relativeLayoutEdit),
                                withParent(withId(android.R.id.content)))),
                        isDisplayed()));
        appCompatEditText.perform(click());
        reportHelper.label("bla");


        ViewInteraction appCompatEditText2 = onView(
                allOf(withId(R.id.titleEdit),
                        withParent(allOf(withId(R.id.relativeLayoutEdit),
                                withParent(withId(android.R.id.content)))),
                        isDisplayed()));
        appCompatEditText2.perform(replaceText("My note"), closeSoftKeyboard());
        reportHelper.label("replace text");


        ViewInteraction appCompatEditText3 = onView(
                allOf(withId(R.id.bodyEdit),
                        withParent(allOf(withId(R.id.scrollView),
                                withParent(withId(R.id.relativeLayoutEdit))))));
        appCompatEditText3.perform(scrollTo(), replaceText("My note content"), closeSoftKeyboard());

        ViewInteraction appCompatImageButton2 = onView(
                allOf(withContentDescription("Navigate up"),
                        withParent(allOf(withId(R.id.toolbarEdit),
                                withParent(withId(R.id.relativeLayoutEdit)))),
                        isDisplayed()));
        appCompatImageButton2.perform(click());

        ViewInteraction appCompatButton = onView(
                allOf(withId(android.R.id.button1), withText("Yes")));
        appCompatButton.perform(scrollTo(), click());

        ViewInteraction textView = onView(
                allOf(withId(R.id.titleView), withText("My note"),
                        childAtPosition(
                                allOf(withId(R.id.relativeLayout),
                                        childAtPosition(
                                                withId(R.id.listView),
                                                0)),
                                0),
                        isDisplayed()));
        textView.check(matches(withText("My note")));

    }

    @Test
    public void testCreateNoteHandCurated() {
        reportHelper.label("MainScreen");

        onView(withId(R.id.newNote)).perform(click()).check(doesNotExist());

        reportHelper.label("NewNote");

        ViewInteraction title = onView(withId(R.id.titleEdit));
        title.perform(click()).check(matches(hasFocus()));

        reportHelper.label("Ready to change title");

        // failed test showed that we only have 30 chars for title
        String uniqTitle = UUID.randomUUID().toString().substring(0, 29);
        title.perform(replaceText(uniqTitle), closeSoftKeyboard());

        reportHelper.label("Replaced title");

        onView(withId(R.id.bodyEdit)).perform(replaceText("My note content"), closeSoftKeyboard());

        onView(allOf(withContentDescription("Navigate up"), withParent(withId(R.id.toolbarEdit))))
                .perform(click());

        onView(withText(R.string.yes_button)).check(matches(isDisplayed()))
            .perform(click());

        reportHelper.label("Back on main screen");

        onData(allOf(is(instanceOf(JSONObject.class)), hasTitle(uniqTitle)))
                .check(matches(withChild(allOf(withId(R.id.titleView), withText(uniqTitle), isDisplayed()))));
        reportHelper.label("My newly created note is in the list");
    }

    private Matcher<JSONObject> hasTitle(final String title) {
        return new TypeSafeMatcher<JSONObject>() {
            @Override
            protected boolean matchesSafely(JSONObject item) {
                return item.has(DataUtils.NOTE_TITLE) &&
                        title.contentEquals(item.optString(DataUtils.NOTE_TITLE));
            }

            @Override
            public void describeTo(Description description) {
                description.appendText(String.format("hasTitle %s", title));
            }
        };
    }

    private static Matcher<View> childAtPosition(
            final Matcher<View> parentMatcher, final int position) {

        return new TypeSafeMatcher<View>() {
            @Override
            public void describeTo(Description description) {
                description.appendText("Child at position " + position + " in parent ");
                parentMatcher.describeTo(description);
            }

            @Override
            public boolean matchesSafely(View view) {
                ViewParent parent = view.getParent();
                return parent instanceof ViewGroup && parentMatcher.matches(parent)
                        && view.equals(((ViewGroup) parent).getChildAt(position));
            }
        };
    }
}
